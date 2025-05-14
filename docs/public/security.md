This section provides information about the main security parameters and its configuration in the Qubership-hue service.

## Exposed Ports

List of ports used by Qubership-hue deployment schema are as follows: 

| Port | Service | Description                                                                            |
|------|---------|----------------------------------------------------------------------------------------|
| 8005 | Hue     | Port for the Hue API.                                                                  |
| 8888 | Hue     | Hue service port.                                                                      |
| 8080 | Trino   | Trino service port. It is available only if Trino is deployed as part of Qubership-hue deployment schema. |

## Secure Protocols

It is possible to enable TLS in Qubership-hue deployment schema. This process is described in the respective [Hue Service Installation Procedure](/docs/public/installation.md#enable-httpstls) guide.

## User Management

There are no predefined local users and roles, but it is possible to manage users according to the _External Hue Documentation_ at [https://docs.gethue.com/administrator/administration/user-management/#users](https://docs.gethue.com/administrator/administration/user-management/#users).

There are no roles entities, but there is a user property: Is admin. Authorization matrix can be configured via groups and permissions. There is one predefined group: default.
Detailed information about available permissions is provided in the external Hue Users guide.

To block the local user account, it is required to perform the steps below.
* Log in to Hue as an administrator.
* Navigate to the user administration section (Admin -> Users).
* Find the user account to be blocked.
* Set the user's status to "Inactive" (or delete the account if temporary blocking is not required).

It is possible to integrate Hue with LDAP and Keycloak, refer to the details in the "Hue with Ldap Integrated User Interface" section of the _[Hue Service Installation Procedure](/docs/public/installation.md#hue-with-ldap-integrated-ui)_ guide.
Hue allows to sync users and groups with LDAP, see details in _External Hue Documentation_ at [[Hue Service Installation Procedure](https://docs.gethue.com/administrator/administration/user-management/#syncing-users-and-groups)](https://docs.gethue.com/administrator/administration/user-management/#syncing-users-and-groups).

## Changing Credentials

A password resetting process for local users is described in the following documentation: [https://docs.gethue.com/administrator/administration/user-management/#reset-a-password)](https://docs.gethue.com/administrator/administration/user-management/#reset-a-password).

Credentials for underlying services are managed in the underlying services. You can configure them in the Qubership-hue deployment schema parameters. For more details refer to:
* "Configuration Trino" in [Hue Service Installation Procedure](https://github.com/Netcracker/qubership-hue/blob/main/docs/public/installation.md#configuration-trino)
* "Hue Service Configuration" in [Hue Service Installation Procedure](/docs/public/configuration-guide.md)

Password policies for local users are not supported in the Qubership-hue deployment schema. Hue uses Django framework for password management, find details in the respective _Official Django Documentation_ at [https://docs.djangoproject.com/en/5.1/topics/auth/passwords/](https://docs.djangoproject.com/en/5.1/topics/auth/passwords/).

## Security Events

To identify the security events in logs, the following packages and key words can be used:

| Security event | Example |
|----------------|-----------|
| Logout | [17/Dec/2024 18:22:28 -0800] database     INFO     AXES: Successful logout by {username: "<user name>", ip_address: "<ip address>", user_agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/0.0.0.0 Safari/537.36", path_info: "/accounts/logout"}. |
| Login | [17/Dec/2024 19:14:45 -0800] database     INFO     AXES: Successful login by {username: "<user name>", ip_address: "<ip address>", user_agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/0.0.0.0 Safari/537.36", path_info: "/hue/accounts/login"}. |
| Failed Login | [17/Dec/2024 19:17:42 -0800] database     WARNING  AXES: Repeated login failure by {username: "<user name>", ip_address: "<ip address>", user_agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/0.0.0.0 Safari/537.36", path_info: "/hue/accounts/login"}. Count = 1 of 3. Updating existing record in the database. |
| Server Start | [17/Dec/2024 19:21:20 -0800] access       INFO     <ip address> -anon- - "GET /desktop/debug/is_alive HTTP/1.1" returned in 50ms 200 0 |

## Session Management

Qubership-hue deployment schema does not support session management. For these purposes, it is recommended to integrate Qubership-hue deployment schema with external user management systems.
