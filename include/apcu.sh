 #!/usr/bin/env bash

Install_Apcu()
{
    echo "You will install apcu..."
    apcu_pass=""
    while :;do
        read -p "Please enter admin password of apcu: " apcu_pass
        if [ "${apcu_pass}" != "" ]; then
            echo "================================================="
            echo "Your admin password of apcu was: ${apcu_pass}"
            echo "================================================="
            break
        else
            Echo_Red "Password cannot be empty!"
        fi
    done
    echo "====== Installing apcu ======"
    Press_Start

    rm -f ${PHP_Path}/conf.d/009-apcu.ini
    Addons_Get_PHP_Ext_Dir
    zend_ext="${zend_ext_dir}apcu.so"
    if [ -s "${zend_ext}" ]; then
        rm -f "${zend_ext}"
    fi

    cd ${cur_dir}/src

    if echo "${Cur_PHP_Version}" | grep -Eqi '^(7.|8.)'; then
        Download_Files ${PHPNewApcu_DL} ${PHPNewApcu_Ver}.tgz
        Tar_Cd ${PHPNewApcu_Ver}.tgz ${PHPNewApcu_Ver}
    else
        Download_Files ${PHPOldApcu_DL} ${PHPOldApcu_Ver}.tgz
        Tar_Cd ${PHPOldApcu_Ver}.tgz ${PHPOldApcu_Ver}
    fi
    ${PHP_Path}/bin/phpize
    ./configure --with-php-config=${PHP_Path}/bin/php-config
    make
    make install
    \cp -a apc.php ${Default_Website_Dir}/apc.php
    sed -i "s/^defaults('ADMIN_PASSWORD','.*/defaults('ADMIN_PASSWORD','${apcu_pass}');/g" ${Default_Website_Dir}/apc.php
    cd ..

    if echo "${Cur_PHP_Version}" | grep -Eqi '^7.'; then
        Download_Files ${PHPApcu_Bc_DL} ${PHPApcu_Bc_Ver}.tgz
        Tar_Cd ${PHPApcu_Bc_Ver}.tgz ${PHPApcu_Bc_Ver}
        ${PHP_Path}/bin/phpize
        ./configure --with-php-config=${PHP_Path}/bin/php-config
        make
        make install
        cd ..
        rm -rf ${cur_dir}/src/${PHPApcu_Bc_Ver}
        rm -rf ${cur_dir}/src/${PHPNewApcu_Ver}
    else
        rm -rf ${cur_dir}/src/${PHPOldApcu_Ver}
    fi

    cat >${PHP_Path}/conf.d/009-apcu.ini<<EOF
[apcu]
extension=apcu.so
apc.enabled=1
apc.shm_size=32M
apc.enable_cli=1

EOF

    if echo "${Cur_PHP_Version}" | grep -Eqi '^7.'; then
        sed -i '/apcu.so/a\extension=apc.so' ${PHP_Path}/conf.d/009-apcu.ini
    fi

    if [ -s "${zend_ext}" ]; then
        Restart_PHP
        Echo_Green "APCu Dashboard: http://yourIP/apc.php "
        Echo_Green "Admin Username: apc"
        Echo_Green "Admin Password: ${apcu_pass}"
        Echo_Green "======== apcu install completed ======"
        Echo_Green "apcu installed successfully, enjoy it!"
    else
        rm -f ${PHP_Path}/conf.d/009-apcu.ini
        Echo_Red "apcu install failed!"
    fi
}

Uninstall_Apcu()
{
    echo "You will uninstall apcu..."
    Press_Start
    rm -f ${PHP_Path}/conf.d/009-apcu.ini
    echo "Delete apcu files..."
    rm -f "${zend_ext}"
    Restart_PHP
    Echo_Green "Uninstall apcu completed."
}
