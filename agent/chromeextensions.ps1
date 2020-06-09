$userdir = dir 'c:\users\'
ForEach ($user in $userdir)
 
  {
    $user_name = $user.name

    if(Test-Path "C:\Users\$user_name\AppData\Local\Google\Chrome\User Data\Default\Extensions"){
        $extension_folders = Get-ChildItem -Path "C:\Users\$user_name\AppData\Local\Google\Chrome\User Data\Default\Extensions"

        foreach ($extension_folder in $extension_folders ) {

            $version_folders = Get-ChildItem -Path "$($extension_folder.FullName)"

            foreach ($version_folder in $version_folders) {

                $appid = $extension_folder.BaseName

                $name = ""
                if( (Test-Path -Path "$($version_folder.FullName)\manifest.json") ) {
                    try {
                        $json = Get-Content -Raw -Path "$($version_folder.FullName)\manifest.json" | ConvertFrom-Json
                        $name = $json.name
                    } catch {
                        #$_
                        $name = ""
                    }
                }

                if( $name -like "*MSG*" ) {
                    if( Test-Path -Path "$($version_folder.FullName)\_locales\en\messages.json" ) {
                        try { 
                            $json = Get-Content -Raw -Path "$($version_folder.FullName)\_locales\en\messages.json" | ConvertFrom-Json
                            $name = $json.appName.message
                            if(!$name) {
                                $name = $json.extName.message
                            }
                            if(!$name) {
                                $name = $json.extensionName.message
                            }
                            if(!$name) {
                                $name = $json.app_name.message
                            }
                            if(!$name) {
                                $name = $json.application_title.message
                            }
                        } catch { 
                            $name = ""
                        }
                    }
                    ##: Sometimes the folder is en_US
                    if( Test-Path -Path "$($version_folder.FullName)\_locales\en_US\messages.json" ) {
                        try {
                            $json = Get-Content -Raw -Path "$($version_folder.FullName)\_locales\en_US\messages.json" | ConvertFrom-Json
                            $name = $json.appName.message
                            if(!$name) {
                                $name = $json.extName.message
                            }
                            if(!$name) {
                                $name = $json.extensionName.message
                            }
                            if(!$name) {
                                $name = $json.app_name.message
                            }
                            if(!$name) {
                                $name = $json.application_title.message
                            }
                        } catch {
                            #$_
                            $name = ""
                        }
                    }
                }

                ##: If we can't get a name from the extension use the app id instead
                if( !$name ) {
                    $name = "[$($appid)]"
                }
                
                $xml += "<CHROMEEXTENSIONS>"
                $xml += "<USERNAME>$user_name</USERNAME>"
                $xml += "<EXTENSIONNAME>$name</EXTENSIONNAME>"
                $xml += "<EXTENSIONVERSION>$version_folder</EXTENSIONVERSION>"
                $xml += "<EXTENSIONID>$appid</EXTENSIONID>"
                $xml += "</CHROMEEXTENSIONS>"

            }

        }
    }

}

[Console]::WriteLine($xml)