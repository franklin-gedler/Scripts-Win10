Function showmenupais {

    Write-Output ""
    Write-Host " ******* Seleccione el pais  ******* "
    Write-Host ""
    Write-Host "                0. Exit              " -ForegroundColor Yellow -BackgroundColor Black
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
    Write-Host "            0. Exit              " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host ""
    Write-Host "            1. SI                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "            2. NO                " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host " ******************************* "
}

Write-Output ""
showmenupais
Write-Output ""

while(($inp = Read-Host -Prompt "Seleccione una Opcion") -ne "0"){
    
    switch($inp){

        0{"Exit"; break}
        default {Write-Host -ForegroundColor Red "Opcion Invalida, por favor seleccione una de las disponibles"}

        1{
                
            Write-Output "Ejecuto para AR"
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

        }
        2{

            Write-Output "Ejecuto para UY"
            

        }
        3{

            Write-Output "Ejecuto para BR"

            # Recuerda que debe haber un menu que pregunte si es PCI o NO

            Write-Output ""
            ShowMenuPci
            Write-Output ""

            while(($inpbr = Read-Host -Prompt "Seleccione una Opcion") -ne "0"){
                
                switch ($inpbr) {

                    0{"Exit"; break}
                    default {Write-Host -ForegroundColor Red "Opcion Invalida, por favor seleccione una de las disponibles"}

                    1{
                        # Cuando es PCI
                        
                    }

                    2{
                        # Cuando no es PCI
                        
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

            while(($inp = Read-Host -Prompt "Seleccione una Opcion") -ne "0"){

                switch ($inp) {
                    
                    0{"Exit"; break}
                    default {Write-Host -ForegroundColor Red "Opcion Invalida, por favor seleccione una de las disponibles"}

                    1{
                        # Cuando es PCI
                         
                    }

                    2{
                        # Cuando no es PCI

                    }
                }

            }
                           
        }
        5{
            Write-Output "Ejecuto para CL"
           

        }
        6{
            Write-Output "Ejecuto para MX"
            

        }
        7{
            Write-Output "Ejecuto para PE"
            
        }
            
    }
    Write-Output ""
    showmenupais
    Write-Output ""
} 