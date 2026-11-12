return function(Adapter, options)
    local config=table.clone(options or {})
    config.executor_profile="lynx"
    return Adapter.install(config)
end
