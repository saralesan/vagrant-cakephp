# Vagrant CakePHP

Author: Sergio Torres

Version: 0.1


A vagrant that setup CakePHP and all its dependencies.

## Prerequisites

* Vagrant
* Virtualbox

## Usage

1. Clone this repository

    ```bass
    git clone https://github.com/sdtorresl/vagrant-cakephp
    ```

1. Edit and modify variables in config.sh file:
    * APP_NAME: The name of your CakePHP app
    * DB_NAME: the name of your database
    * DB_USER: User of the database
    * DB_PASSWORD: Password of the database

1. Execute with vagrant:

    ```bash
    cd vagrant-cakephp---
    vagrant up
    ```

1. Check installation in your web browser (replacing APP_NAME var):

    ```javascript
    http:/192.168.33.10/APP_NAME
    ```
