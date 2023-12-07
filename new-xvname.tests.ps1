BeforeAll {
    . $PSScriptroot\new-xvmname.ps1
}
  Describe 'new-xvmname function' {
    It 'the vmname should not be in vms' {
        new-xvmname -vms $vms -os W -vm_env P -customer HORI | Should -Not -BeIn $vms
    }
    It 'the function should return only 1 vm' {
        (new-xvmname -vms $vms -os W -vm_env P -customer HORI).count | Should -Be 1
    }
    It 'the function should return X names' {
        foreach ($i in (1..50)){
            $data = new-xvmname -vms $vms -os W -vm_env P -customer HORI -number_of_names $i
            $data.count | Should -Be $i
            $data | Should -Not -BeIn $vms
            $data | Should -Match $regex
        }
    }
    It 'the function should return a count of 1' {
        (new-xvmname -vms $vms -os W -vm_env P -customer HORI).count | Should -be 1
    }
    It 'parameters should be mandatory' {
        (Get-Command new-xvmname).Parameters['customer'].Attributes.Mandatory | Should -Be $true
        (Get-Command new-xvmname).Parameters['vms'].Attributes.Mandatory | Should -Be $true
        (Get-Command new-xvmname).Parameters['os'].Attributes.Mandatory | Should -Be $true
        (Get-Command new-xvmname).Parameters['vm_env'].Attributes.Mandatory | Should -Be $true
    }
    It 'the vmname should work with different client quadris' {
        foreach ($quadri in  $quadris){
            $data = new-xvmname -vms $vms -os W -vm_env P -customer $quadri
            $data | Should -Not -BeIn $vms
            $data | Should -Match $regex
        }
    }
    It 'the vmname should work with different client os' {
        foreach ($os in  $oss){
            $data = new-xvmname -vms $vms -os $os -vm_env P -customer HORI
            $data | Should -Not -BeIn $vms
            $data | Should -Match $regex
        }
    }
    It 'the vmname should work with different environment' {
        foreach ($environment in  $environments){
            $data = new-xvmname -vms $vms -os L -vm_env $environment -customer HORI
            $data | Should -Not -BeIn $vms
            $data | Should -Match $regex
        }
    }
    It 'the function should run under a minut' {
        $seconds = (Measure-Command {
            new-xvmname -vms $vms -os L -vm_env P -customer HORI
        }).TotalSeconds

        $seconds | Should -BeLessOrEqual 60
    }
}