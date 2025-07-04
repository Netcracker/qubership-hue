This document describes the architectural features of the Qubership-hue service. The following topics are covered in the document:

* [Overview](#overview)
  * [Qubership-hue Deployment Schema](#qubership-hue-deployment-schema)
* [Supported Deployment Scheme](#supported-deployment-scheme)
  * [Non-HA Deployment Scheme](#non-ha-deployment-scheme)
* [Examples of Database Connections](#examples-of-database-connections)

# Overview

This section provides an overview of Qubership-hue service.

## Qubership-hue Deployment Schema

Qubership-hue project provides images and helm charts to deploy hue and trino to Kuberneetes. Helm charts are based on [hue](https://github.com/gethue/hue/tree/master/tools/kubernetes/helm/hue) with some modifications.
Hue is a mature SQL Assistant for querying Databases & Data Warehouses.
Trino is used to connect to the databases that are not covered by Hue support.

# Supported Deployment Scheme

The information on the supported deployment schemes is provided in the below sub-sections.

## Non-HA Deployment Scheme

Qubership-hue deployment schema in the non-HA mode has only one replica of each component. 

![Qubership-hue deployment Schema non-HA Scheme](/docs/public/images/qubership-hue-non-ha-scheme.png)

Structure service:

## Hue

The Hue components are described below.

* `UI` - The user interface for working with Hue.
* `Hue Server` - The Hue server, which functions as part of a cluster, is a part of the server tier. In addition to communicating with the client tier, it offers the necessary services.
* `Hue Apps` - Hue connects to any database or warehouse through native Thrift or SqlAlchemy connectors that need to be added to the Hue ini file. Except [impala] and [beeswax], which have a dedicated section, all the other ones should be appended below the [[interpreters]] of [notebook]. For example:
  * `beeswax` - Connector for connecting to Hive.
  * `sqlalchemy` - Connector for connecting to Trino.
  * `alternative connector` - The list of alternative connectors is available at [https://docs.gethue.com/administrator/configuration/connectors/](https://docs.gethue.com/administrator/configuration/connectors/).
* `Hue DB` - The database for Hue hosted in PostgreSQL.

## Trino

The Trino components are described below.

`DB(Table Structure Store)` - A list of connectors for connecting databases through Trino. For more information, refer to the _Official Documentation_ at [https://trino.io/docs/current/connector.html](https://trino.io/docs/current/connector.html).

# Examples of Database Connections

Examples of connections to SQL and NoSQL databases can be found in the [Hue Service Configuration](/docs/public/configuration-guide.md) section.
