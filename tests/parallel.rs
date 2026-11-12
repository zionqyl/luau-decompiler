use luau_decompiler::{
    bytecode, decompile, decompile_batch, decompile_with_threads, Config, Limits,
};

#[test]
fn bounded_function_analysis_and_batch_output_are_deterministic() {
    let large = include_bytes!("fixtures/many_functions.O1.D2.bc");
    assert!(
        bytecode::decode(large, &Limits::default())
            .unwrap()
            .protos
            .len()
            >= 16
    );
    let config = Config::default();
    let expected = decompile(large, &config).unwrap().source;
    for threads in [1, 2, 4] {
        assert_eq!(
            decompile_with_threads(large, &config, threads)
                .unwrap()
                .source,
            expected
        );
    }
    let inputs = vec![
        large.to_vec(),
        vec![255],
        include_bytes!("fixtures/closures.O2.D0.bc").to_vec(),
        large.to_vec(),
    ];
    let expected: Vec<_> = inputs
        .iter()
        .map(|input| {
            decompile(input, &config)
                .map(|result| result.source)
                .map_err(|e| e.to_string())
        })
        .collect();
    for threads in [1, 2, 4] {
        let actual: Vec<_> = decompile_batch(&inputs, &config, threads)
            .unwrap()
            .into_iter()
            .map(|result| {
                result
                    .map(|result| result.source)
                    .map_err(|e| e.to_string())
            })
            .collect();
        assert_eq!(actual, expected);
    }
    assert!(decompile_with_threads(large, &config, 0).is_err());
    assert!(decompile_batch(&inputs, &config, 257).is_err());
}
