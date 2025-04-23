# Deploying hue with non kerberized and non HA hadoop for testing purposes.

It is possible to deploy hue with non-kerberized non-HA hadoop to access hive. In this case for hive connector it is not necessary to specify `hive_conf_dir` and `use_sasl` must be set to true. For example:

```yaml
hue:
...
  interpreters: |
    [[[hive]]]
    name=Hive

    interface=hiveserver2

    [beeswax]
    hive_server_host=<hive server host url>
    hive_server_port=10000
    use_sasl=true
...
```