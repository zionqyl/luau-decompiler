#[cfg(not(target_arch = "wasm32"))]
pub use std::time::Instant;

#[cfg(target_arch = "wasm32")]
mod browser_clock {
    use std::ops::{Add, Sub};
    use std::time::Duration;
    use wasm_bindgen::prelude::*;

    #[wasm_bindgen]
    extern "C" {
        #[wasm_bindgen(js_namespace = performance, js_name = now)]
        fn performance_now() -> f64;
    }

    #[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)]
    pub struct Instant(u64);

    impl Instant {
        pub fn now() -> Self {
            Self((performance_now().max(0.0) * 1000.0) as u64)
        }

        pub fn elapsed(self) -> Duration {
            Self::now() - self
        }

        pub fn duration_since(self, earlier: Self) -> Duration {
            self - earlier
        }
    }

    impl Add<Duration> for Instant {
        type Output = Self;
        fn add(self, duration: Duration) -> Self {
            Self(
                self.0
                    .saturating_add(duration.as_micros().min(u64::MAX as u128) as u64),
            )
        }
    }

    impl Sub<Duration> for Instant {
        type Output = Self;
        fn sub(self, duration: Duration) -> Self {
            Self(
                self.0
                    .saturating_sub(duration.as_micros().min(u64::MAX as u128) as u64),
            )
        }
    }

    impl Sub for Instant {
        type Output = Duration;
        fn sub(self, earlier: Self) -> Duration {
            Duration::from_micros(self.0.saturating_sub(earlier.0))
        }
    }
}

#[cfg(target_arch = "wasm32")]
pub use browser_clock::Instant;
