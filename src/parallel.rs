#[cfg(not(target_arch = "wasm32"))]
pub use rayon::{current_num_threads, current_thread_index, ThreadPool, ThreadPoolBuilder};

#[cfg(not(target_arch = "wasm32"))]
pub mod prelude {
    pub use rayon::prelude::*;
}

#[cfg(target_arch = "wasm32")]
pub mod prelude {
    pub trait ParallelSlice<T> {
        fn par_iter(&self) -> std::slice::Iter<'_, T>;
    }
    impl<T> ParallelSlice<T> for [T] {
        fn par_iter(&self) -> std::slice::Iter<'_, T> {
            self.iter()
        }
    }
    pub trait IntoParallelIterator: IntoIterator + Sized {
        fn into_par_iter(self) -> Self::IntoIter {
            self.into_iter()
        }
    }
    impl<T: IntoIterator> IntoParallelIterator for T {}
}

#[cfg(target_arch = "wasm32")]
pub fn current_thread_index() -> Option<usize> {
    None
}
#[cfg(target_arch = "wasm32")]
pub fn current_num_threads() -> usize {
    1
}
#[cfg(target_arch = "wasm32")]
pub struct ThreadPool;
#[cfg(target_arch = "wasm32")]
impl ThreadPool {
    pub fn current_num_threads(&self) -> usize {
        1
    }
    pub fn install<T: Send>(&self, work: impl FnOnce() -> T + Send) -> T {
        work()
    }
}
#[cfg(target_arch = "wasm32")]
#[derive(Default)]
pub struct ThreadPoolBuilder {
    threads: usize,
}
#[cfg(target_arch = "wasm32")]
impl ThreadPoolBuilder {
    pub fn new() -> Self {
        Self { threads: 1 }
    }
    pub fn num_threads(mut self, threads: usize) -> Self {
        self.threads = threads;
        self
    }
    pub fn thread_name(self, _: impl FnMut(usize) -> String + Send + 'static) -> Self {
        self
    }
    pub fn build(self) -> std::result::Result<ThreadPool, String> {
        if self.threads != 1 {
            return Err("browser engine supports one synchronous worker per instance; use the bounded browser supervisor for independent jobs".into());
        }
        Ok(ThreadPool)
    }
}
