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
    #Write-Host ""
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

    $InputOffice365 = Read-Host -Prompt "Seleccione una Opcion Para office"
    switch ($InputOffice365) {

        0{
            MainAction
        }

        1{
            Write-Host "instalo office";
            #Write-Output '1' > C:\Users\admindesp\Desktop\Office365.txt 
        }
        
    }
}

function MainAction {
    
    Write-Output ""
    showmenupais
    Write-Output ""

    while($inp = Read-Host -Prompt "Seleccione una Opcion Pais"){
        
        switch($inp){

            default {Write-Host -ForegroundColor Red "Opcion Invalida, por favor seleccione una de las disponibles"}

            1{
                
                Write-Output "Ejecuto para AR"
                ActionOffice365  # llamo a la funcion de Office365
                <#
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
                #>
                
                Exit  # Este exit le devuelve el control al script de ProcessUpdateRegional
            }
            2{

                Write-Output "Ejecuto para UY"
                
                Exit  # Este exit le devuelve el control al script de ProcessUpdateRegional
            }
            3{

                Write-Output "Ejecuto para BR"

                # Recuerda que debe haber un menu que pregunte si es PCI o NO

                Write-Output ""
                ShowMenuPci
                Write-Output ""

                while($inpbr = Read-Host -Prompt "Seleccione una Opcion PCI"){
                    
                    switch ($inpbr) {

                        default {Write-Host -ForegroundColor Red "Opcion Invalida, por favor seleccione una de las disponibles"}

                        1{
                            # Cuando es PCI
                            Write-Output "BR PCI"


                            Exit  # Este exit le devuelve el control al script de ProcessUpdateRegional
                        }

                        2{
                            # Cuando no es PCI
                            Write-Output "BR Comun"

                            Exit  # Este exit le devuelve el control al script de ProcessUpdateRegional
                        }
                    }
                }
                
            }
            4{

                Write-Output "Ejecuto para CO"
                
                # Recuerda que debe haber un menu que pregunte si es PCI o NO

                Write-Output ""
                ShowMenuPci
                Write-Output ""

                while($inp = Read-Host -Prompt "Seleccione una Opcion"){

                    switch ($inp) {
                        
                        default {Write-Host -ForegroundColor Red "Opcion Invalida, por favor seleccione una de las disponibles"}

                        1{
                            # Cuando es PCI
                            Write-Host "CO PCI"
                            Exit  # Este exit le devuelve el control al script de ProcessUpdateRegional
                        }

                        2{
                            # Cuando no es PCI
                            Write-Host "CO Comun"

                            Exit  # Este exit le devuelve el control al script de ProcessUpdateRegional
                        }
                    }

                }
                            
            }
            5{
                Write-Output "Ejecuto para CL"
            
                Exit  # Este exit le devuelve el control al script de ProcessUpdateRegional
            }
            6{
                Write-Output "Ejecuto para MX"
                
                Exit  # Este exit le devuelve el control al script de ProcessUpdateRegional
            }
            7{
                Write-Output "Ejecuto para PE"
                
                Exit  # Este exit le devuelve el control al script de ProcessUpdateRegional
            }
                
        }
        Write-Output ""
        showmenupais
        Write-Output ""
    } 
    
}

MainAction