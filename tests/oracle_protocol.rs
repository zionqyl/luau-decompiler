mod oracle;
#[cfg(test)]
mod tests {
    use crate::oracle::*;
    fn observation(values: Vec<Value>) -> Observation {
        Observation {
            protocol: PROTOCOL,
            complete: true,
            events: vec![],
            outcome: Outcome::Return,
            terminal: values,
        }
    }
    fn roundtrip(values: Vec<Value>) -> Observation {
        let frame = observation(values).encode().unwrap();
        Observation::decode(&frame).unwrap()
    }
    #[test]
    fn number_and_string_cannot_compare_equal() {
        assert!(!roundtrip(vec![Value::Number(1f64.to_bits())])
            .equivalent(&roundtrip(vec![Value::String(b"1".to_vec())])));
    }
    #[test]
    fn nil_and_string_cannot_compare_equal() {
        assert!(!roundtrip(vec![Value::Nil])
            .equivalent(&roundtrip(vec![Value::String(b"nil".to_vec())])));
    }
    #[test]
    fn ambiguous_tab_tuples_and_return_counts_remain_distinct() {
        let one = roundtrip(vec![Value::String(b"a\tb".to_vec())]);
        let two = roundtrip(vec![
            Value::String(b"a".to_vec()),
            Value::String(b"b".to_vec()),
        ]);
        assert!(!one.equivalent(&two));
        assert!(!roundtrip(vec![]).equivalent(&roundtrip(vec![Value::Nil])));
        assert!(!roundtrip(vec![Value::Nil]).equivalent(&roundtrip(vec![Value::Nil, Value::Nil])));
    }
    #[test]
    fn invalid_utf8_nuls_crlf_and_newlines_remain_exact() {
        for (a, b) in [
            (vec![0xff], vec![0xfe]),
            (b"a\0b".to_vec(), b"a\0c".to_vec()),
            (b"\r\n".to_vec(), b"\n".to_vec()),
        ] {
            assert!(
                !roundtrip(vec![Value::String(a)]).equivalent(&roundtrip(vec![Value::String(b)]))
            );
        }
    }
    #[test]
    fn numeric_zero_nan_and_infinity_bits_are_preserved() {
        for (a, b) in [
            (0f64.to_bits(), (-0f64).to_bits()),
            (0x7ff8_0000_0000_0001, 0x7ff8_0000_0000_0002),
            (f64::INFINITY.to_bits(), f64::NEG_INFINITY.to_bits()),
        ] {
            assert!(
                !roundtrip(vec![Value::Number(a)]).equivalent(&roundtrip(vec![Value::Number(b)]))
            );
        }
    }
    #[test]
    fn ordered_effects_and_typed_errors_are_compared() {
        let mut a = observation(vec![Value::String(b"failure\0\xff".to_vec())]);
        a.outcome = Outcome::Error;
        let mut b = a.clone();
        b.terminal = vec![Value::Boolean(false)];
        assert!(!a.equivalent(&b));
        b = a.clone();
        b.outcome = Outcome::Return;
        assert!(!a.equivalent(&b));
        a.events = vec![
            Event {
                kind: EffectKind::Print,
                values: vec![Value::Number(1f64.to_bits())],
            },
            Event {
                kind: EffectKind::Warn,
                values: vec![Value::Nil],
            },
        ];
        b = a.clone();
        b.events.reverse();
        assert!(!a.equivalent(&b));
    }
    #[test]
    fn incomplete_opaque_and_harness_results_never_count_as_success() {
        let mut opaque = observation(vec![Value::Opaque {
            vm_type: 6,
            identity: 1,
        }]);
        opaque.complete = false;
        let opaque = Observation::decode(&opaque.encode().unwrap()).unwrap();
        assert!(!opaque.equivalent(&opaque));
        let mut timeout = observation(vec![Value::String(b"deadline".to_vec())]);
        timeout.outcome = Outcome::Timeout;
        assert!(!timeout.equivalent(&timeout));
        let mut false_claim = opaque;
        false_claim.complete = true;
        assert!(!false_claim.verified());
        assert!(Observation::decode(&false_claim.encode().unwrap()).is_err());
    }
    #[test]
    fn truncation_trailing_bytes_and_invalid_flags_fail() {
        let frame = observation(vec![
            Value::String(vec![0, 255, 9]),
            Value::Number(42f64.to_bits()),
        ])
        .encode()
        .unwrap();
        for end in 0..frame.len() {
            assert!(Observation::decode(&frame[..end]).is_err());
        }
        let mut bad = frame.clone();
        bad.push(0);
        assert!(Observation::decode(&bad).is_err());
        bad = frame;
        bad[5] = 2;
        assert!(Observation::decode(&bad).is_err());
    }
}
