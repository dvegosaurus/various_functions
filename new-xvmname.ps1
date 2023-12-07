function new-xvmname {

    [cmdletbinding()]
    param(
        [parameter(mandatory=$true)]
        $vms,
        [parameter(mandatory=$true)]
        [validateset("L","W")]
        $os,
        [parameter(mandatory=$true)]
        [validateset("P","D")]
        $vm_env,
        [parameter(mandatory=$true)]
        $customer,
        $number_of_names=1
    )

    $digit = 1   # initialize the lowest digit
    $max_digit = 3 # 000
    $nonamefound = $true
    $names = @()

    while ($nonamefound){
        
        # convert a digit to a string with a lenght of $max_digit
        $number_to_string = $digit.ToString()
        $zero_to_add = $max_digit - $number_to_string.Length
        $number_to_string = ("0" * $zero_to_add) + $number_to_string 
   
        # generate a vm name
        $name = $customer+"-"+$vm_env+$os+"APP"+$number_to_string 

        if ($name -notin $vms){$names += $name} # if the vm name does not exist > add it to the list of available name
        if ($number_of_names -eq $names.count){return $names} # if we reached the number of names we want > return the data

        $digit++
    }
}

$vms = @(
        "HORI-PLAPP001"
        "HORI-PLAPP002"
        "HORI-PLAPP003"
        "HORI-PLAPP004"
        "HORI-PLAPP005"
        "HORI-PLAPP006"
        "HORI-PLAPP007"
        "HORI-PLAPP008"
        "HORI-PLAPP009"
        "HORI-PLAPP011"
        "HORI-PLAPP013"
        "HORI-PWAPP013"
        "HORI-PWAPP013"
        "HORI-PWAPP015"
        "HORI-PWAPP002"
        "HORI-PWAPP020"
        "HORI-PWAPP012"
        "HORI-PWAPP030"
        "HORI-PWAPP021"
        "HORI-PWAPP022"
        "HORI-PWAPP029"
        "HORI-DWAPP029"
        "HORI-PLAPP029"
        )

    $quadris = @(
        "HORI"
        "SPFR"
        "TEST"
        "TOUA"
        "GLF1"
        )
    $oss = @(
        "L"
        "W"

    )
    $environments = @(
        "P"
        "D"

    )

    $regex = "^[^@]{4}-(P|D)(W|L)"


new-xvmname -vms $vms -os W -vm_env P -customer HORI -number_of_names 30

