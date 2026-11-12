use luau_decompiler::{decompile, Config};
use serde_json::json;
use sha2::{Digest, Sha256};
use std::alloc::{GlobalAlloc, Layout, System};
use std::sync::atomic::{AtomicBool, AtomicUsize, Ordering::Relaxed};
use std::sync::Mutex;

struct CountingAllocator;
static ENABLED: AtomicBool = AtomicBool::new(false);
static ALLOCS: AtomicUsize = AtomicUsize::new(0);
static REALLOCS: AtomicUsize = AtomicUsize::new(0);
static REQUESTED: AtomicUsize = AtomicUsize::new(0);
static LIVE: AtomicUsize = AtomicUsize::new(0);
static PEAK: AtomicUsize = AtomicUsize::new(0);
static STACKS_ENABLED: AtomicBool = AtomicBool::new(false);
static SAMPLE_COUNT: AtomicUsize = AtomicUsize::new(0);
static SAMPLES: Mutex<Vec<StackSample>> = Mutex::new(Vec::new());
const SAMPLE_INTERVAL: usize = 256;
const MAX_SAMPLES: usize = 64;
#[derive(Clone, Copy)]
struct StackSample {
    addresses: [usize; 24],
    depth: usize,
    bytes: usize,
}

#[cfg(windows)]
#[link(name = "kernel32")]
unsafe extern "system" {
    fn RtlCaptureStackBackTrace(
        skip: u32,
        count: u32,
        frames: *mut *mut std::ffi::c_void,
        hash: *mut u32,
    ) -> u16;
    fn GetModuleHandleW(name: *const u16) -> *mut std::ffi::c_void;
}

fn sample_stack(sequence: usize, bytes: usize) {
    if !STACKS_ENABLED.load(Relaxed) || sequence % SAMPLE_INTERVAL != 0 {
        return;
    }
    #[cfg(windows)]
    {
        let index = SAMPLE_COUNT.fetch_add(1, Relaxed);

        let hash = (index as u64).wrapping_add(0x9e3779b97f4a7c15);
        let hash = (hash ^ (hash >> 30)).wrapping_mul(0xbf58476d1ce4e5b9);
        let hash = (hash ^ (hash >> 27)).wrapping_mul(0x94d049bb133111eb);
        let slot = if index < MAX_SAMPLES {
            index
        } else {
            ((hash ^ (hash >> 31)) % (index as u64 + 1)) as usize
        };
        if slot >= MAX_SAMPLES {
            return;
        }
        if let Ok(mut samples) = SAMPLES.try_lock() {
            let mut sample = StackSample {
                addresses: [0; 24],
                depth: 0,
                bytes,
            };

            sample.depth = unsafe {
                RtlCaptureStackBackTrace(
                    2,
                    24,
                    sample.addresses.as_mut_ptr().cast(),
                    std::ptr::null_mut(),
                )
            } as usize;
            if slot == samples.len() {
                samples.push(sample);
            } else if slot < samples.len() {
                samples[slot] = sample;
            }
        }
    }
    #[cfg(not(windows))]
    let _ = bytes;
}

fn allocated(size: usize) {
    let live = LIVE.fetch_add(size, Relaxed) + size;
    PEAK.fetch_max(live, Relaxed);
}

unsafe impl GlobalAlloc for CountingAllocator {
    unsafe fn alloc(&self, layout: Layout) -> *mut u8 {
        let pointer = unsafe { System.alloc(layout) };
        if !pointer.is_null() {
            allocated(layout.size());
            if ENABLED.load(Relaxed) {
                let sequence = ALLOCS.fetch_add(1, Relaxed) + REALLOCS.load(Relaxed);
                REQUESTED.fetch_add(layout.size(), Relaxed);
                sample_stack(sequence, layout.size());
            }
        }
        pointer
    }
    unsafe fn dealloc(&self, pointer: *mut u8, layout: Layout) {
        LIVE.fetch_sub(layout.size(), Relaxed);
        unsafe { System.dealloc(pointer, layout) };
    }
    unsafe fn realloc(&self, pointer: *mut u8, layout: Layout, size: usize) -> *mut u8 {
        let result = unsafe { System.realloc(pointer, layout, size) };
        if !result.is_null() {
            if size >= layout.size() {
                allocated(size - layout.size());
            } else {
                LIVE.fetch_sub(layout.size() - size, Relaxed);
            }
            if ENABLED.load(Relaxed) {
                let sequence = REALLOCS.fetch_add(1, Relaxed) + ALLOCS.load(Relaxed);
                REQUESTED.fetch_add(size, Relaxed);
                sample_stack(sequence, size);
            }
        }
        result
    }
}

#[global_allocator]
static ALLOCATOR: CountingAllocator = CountingAllocator;

fn main() {
    let mut rows = Vec::new();
    let mut config = Config::default();

    config.validation.mode = luau_decompiler::quality::ValidationMode::Off;
    let mut paths = Vec::new();
    let mut args = std::env::args().skip(1);
    let mut stack_sampling = false;
    while let Some(arg) = args.next() {
        match arg.as_str() {
            "--config" => {
                let path = args.next().expect("--config requires a JSON path");
                config = serde_json::from_slice(&std::fs::read(path).expect("read config"))
                    .expect("parse config");
            }
            "--stacks" => stack_sampling = true,
            _ if arg.starts_with('-') => panic!("unknown option {arg}"),
            _ => paths.push(arg),
        }
    }
    config.validate().expect("valid config");
    if config.validation.mode != luau_decompiler::quality::ValidationMode::Off {
        eprintln!("core allocation profiling requires validation.mode=off; measure strict validation separately");
        std::process::exit(2);
    }
    if stack_sampling && !cfg!(windows) {
        eprintln!("--stacks currently requires Windows; counters work on other platforms");
        std::process::exit(2);
    }
    SAMPLES.lock().unwrap().reserve_exact(MAX_SAMPLES);
    let mut failed = false;
    for path in paths {
        let bytes = std::fs::read(&path).unwrap_or_else(|error| {
            eprintln!("{path}: {error}");
            std::process::exit(2)
        });
        ALLOCS.store(0, Relaxed);
        REALLOCS.store(0, Relaxed);
        REQUESTED.store(0, Relaxed);
        SAMPLE_COUNT.store(0, Relaxed);
        SAMPLES.lock().unwrap().clear();
        let baseline = LIVE.load(Relaxed);
        PEAK.store(baseline, Relaxed);
        STACKS_ENABLED.store(stack_sampling, Relaxed);
        ENABLED.store(true, Relaxed);
        let result = decompile(&bytes, &config);
        ENABLED.store(false, Relaxed);
        STACKS_ENABLED.store(false, Relaxed);
        let (allocations, reallocations, requested, peak) = (
            ALLOCS.load(Relaxed),
            REALLOCS.load(Relaxed),
            REQUESTED.load(Relaxed),
            PEAK.load(Relaxed).saturating_sub(baseline),
        );
        failed |= result.is_err();
        let map_storage = result.as_ref().ok().map(|output| {
            let mut kinds = std::collections::BTreeMap::<&str,usize>::new();
            let kind_bytes = 0usize;
            let mut transformation_bytes = 0usize;
            let mut binding_bytes = 0usize;
            for region in &output.source_map {
                *kinds.entry(region.kind.as_str()).or_default() += 1;
                binding_bytes += region.binding.as_ref().map_or(0, String::capacity);
                transformation_bytes += region.transformations.capacity() * std::mem::size_of::<String>();
                transformation_bytes += region.transformations.iter().map(String::capacity).sum::<usize>();
            }
            json!({"regions":output.source_map.len(),"region_vector_bytes":output.source_map.capacity()*std::mem::size_of::<luau_decompiler::types::GeneratedRegion>(),"kind_string_bytes":kind_bytes,"binding_string_bytes":binding_bytes,"transformation_storage_bytes":transformation_bytes,"kinds":kinds})
        });
        #[cfg(windows)]
        let image_base = unsafe { GetModuleHandleW(std::ptr::null()) } as usize;
        #[cfg(not(windows))]
        let image_base = 0usize;
        let samples:Vec<_> = SAMPLES.lock().unwrap().iter().map(|sample|json!({"allocation_bytes":sample.bytes,"addresses":sample.addresses[..sample.depth].iter().map(|address|format!("0x{address:x}")).collect::<Vec<_>>(),"image_relative_addresses":sample.addresses[..sample.depth].iter().map(|address|format!("0x{:x}",address.saturating_sub(image_base))).collect::<Vec<_>>()})).collect();
        rows.push(json!({"path": path, "input_bytes": bytes.len(), "allocations": allocations,
            "reallocations": reallocations, "bytes_requested": requested, "peak_additional_live_heap_bytes": peak,
            "final_source_map_storage":map_storage,"allocation_stack_samples":samples,"sample_candidates":SAMPLE_COUNT.load(Relaxed),"loaded_image_base":format!("0x{image_base:x}"),
            "source_sha256":result.as_ref().ok().map(|output|format!("{:x}",Sha256::digest(output.source.as_bytes()))),
            "result": result.map(|result| result.stats).map_err(|error| error.to_string())}));
    }
    if rows.is_empty() {
        eprintln!("provide one or more bytecode files");
        std::process::exit(2);
    }
    println!("{}", serde_json::to_string_pretty(&json!({"schema": 2,"config":config,"stack_sampling":stack_sampling,"sample_interval":SAMPLE_INTERVAL,"sample_capacity":MAX_SAMPLES,
        "note": "single-threaded System allocator instrumentation; excludes loaded inputs; requested bytes count full realloc requests; timings have instrumentation overhead; heap excludes stacks and allocator metadata",
        "results": rows})).unwrap());
    if failed {
        std::process::exit(1);
    }
}
