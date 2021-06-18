Function showmenupais {

    Write-Output ""
    Write-Host " ******* Seleccione el pais  ******* "
    #Write-Host ""
    #Write-Host "                0. Atras             " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host ""
    Write-Host "                1. AR                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "                2. UY                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "                3. BR                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "                4. CO                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "                5. CL                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "                6. MX                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "                7. PE                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host " *********************************** "
}

function ShowMenuPci {
    
    Write-Output ""
    Write-Host " *** ¿Va ser PCI el equipo? ***  "
    Write-Host ""
    Write-Host "            0. Atras             " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host ""
    Write-Host "            1. SI                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "            2. NO                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host " ******************************* "
}

function ShowMenuOffice365 {
    
    Write-Output ""
    Write-Host " *** ¿Desea Instalar Office365? ***  "
    Write-Host ""
    Write-Host "               0. Atras               " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host ""
    Write-Host "               1. SI                 " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "               2. NO                 " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host " *********************************** "
}

function ActionOffice365 {
    
    Write-Output ""
    ShowMenuOffice365
    Write-Output ""

    #$InputOffice365 = Read-Host -Prompt "Seleccione una Opcion Para office"
    switch (Read-Host -Prompt "Seleccione una Opcion Para Office") {

        0{
            MainAction
        }

        1{
            #Write-Host "instalo office";
            Write-Output '1' > C:\Users\admindesp\Desktop\Office365.txt
        }
        
        2{
            Write-Output '0' > C:\Users\admindesp\Desktop\Office365.txt
        }
    }
}

function ActionPCI {
    Write-Output ""
    ShowMenuPci
    Write-Output ""

    while($inpPCI = Read-Host -Prompt "Seleccione una Opcion PCI"){
        
        switch ($inpPCI) {

            default {Write-Host -ForegroundColor Red "Opcion Invalida, por favor seleccione una de las disponibles"}

            0{
                MainAction
            }

            1{
                # Cuando es PCI
                Write-Output "Es PCI"
                ActionOffice365  # llamo a la funcion de Office365



                Exit  # Este exit le devuelve el control al script de ProcessUpdateRegional
            }

            2{
                # Cuando no es PCI
                Write-Output "No es PCI"
                ActionOffice365  # llamo a la funcion de Office365



                Exit  # Este exit le devuelve el control al script de ProcessUpdateRegional
            }
        }
    }
    
}

function MainAction {

    # Mi firma ##################
    . C:\PrepareWin10\Firma.ps1 #
    #############################
    
    Write-Output ""
    showmenupais
    Write-Output ""

    while($inp = Read-Host -Prompt "Seleccione una Opcion Pais"){
        
        switch($inp){

            default {Write-Host -ForegroundColor Red "Opcion Invalida, por favor seleccione una de las disponibles"}

            1{
                
                Write-host "        Seleccionastes AR          " -ForegroundColor Yellow -BackgroundColor Black
                
                ActionOffice365  # llamo a la funcion de Office365
                
                Write-Output 'AR' > C:\PrepareWin10\Pais.txt
                Write-Output '54' > C:\PrepareWin10\CodigoPais.txt

                # Solicito y Valido Credenciales de Soporte IT -----------------
                . C:\PrepareWin10\VerifyCred.ps1
                VerifyCred "AR" "54"
                #---------------------------------------------------------------

                # Sincronizo hora y la seteo para que la tome del AD -----------
                . C:\PrepareWin10\TimeSet.ps1
                TimeSet "Argentina Standard Time"
                #---------------------------------------------------------------
                
                # Cambio nombre al equipo --------------------------------------
                . C:\PrepareWin10\ChangeName.ps1   # Cargo la funcion en memoria
                ChangeName "AR"
                #---------------------------------------------------------------
                Pause
                
                Exit  # Este exit le devuelve el control al script de ProcessUpdateRegional
            }

            2{

                Write-host "        Seleccionastes UY          " -ForegroundColor Yellow -BackgroundColor Black
                ActionOffice365  # llamo a la funcion de Office365
                Exit  # Este exit le devuelve el control al script de ProcessUpdateRegional
            }

            3{

                Write-host "        Seleccionastes BR          " -ForegroundColor Yellow -BackgroundColor Black
                ActionPCI    # Menu con sus tareas dependiendo si es PCI o NO

                # Nota: el Exit lo tiene la funcion ActionPCI
            }

            4{
                Write-host "        Seleccionastes CO          " -ForegroundColor Yellow -BackgroundColor Black
                ActionPCI    # Menu con sus tareas dependiendo si es PCI o NO
                
                # Nota: el Exit lo tiene la funcion ActionPCI       
            }

            5{
                Write-host "        Seleccionastes CL          " -ForegroundColor Yellow -BackgroundColor Black
                ActionOffice365  # llamo a la funcion de Office365
                Exit  # Este exit le devuelve el control al script de ProcessUpdateRegional
            }

            6{
                Write-host "        Seleccionastes MX          " -ForegroundColor Yellow -BackgroundColor Black
                ActionOffice365  # llamo a la funcion de Office365
                Exit  # Este exit le devuelve el control al script de ProcessUpdateRegional
            }

            7{
                Write-host "        Seleccionastes PE          " -ForegroundColor Yellow -BackgroundColor Black
                ActionOffice365  # llamo a la funcion de Office365
                Exit  # Este exit le devuelve el control al script de ProcessUpdateRegional
            }
                
        }
        Write-Output ""
        showmenupais
        Write-Output ""
    } 
    
}