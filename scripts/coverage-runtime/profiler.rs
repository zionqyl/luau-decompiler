
#![allow(internal_features)]
#![feature(no_core)]
#![feature(profiler_runtime)]
#![feature(staged_api)]



#![no_core]
#![profiler_runtime]
#![unstable(
    feature = "profiler_runtime_lib",
    reason = "internal implementation detail of rustc right now",
    issue = "none"
)]

#[link(name="profiler-rt", kind="static")] unsafe extern "C" {}
