
return function(Adapter, options)
    local config=table.clone(options or {})
    config.executor_profile="volt"
    return Adapter.install(config)
end
