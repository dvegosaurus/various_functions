
BeforeAll {
    . $psscriptroot\powermanage-server.ps1
}

Describe 'restart server' {
    context 'basic test'{
        it 'should be true' {
            $true | Should -be $true
        }
    }
    context 'data check'{
        it 'data should have a name propertie'   { ($servers.name  | where {$_} ).count | Should -BeExactly $servers.count}
        it 'data should have a lot propertie'    { ($servers.lot   | where {$_} ).count | Should -BeExactly $servers.count}
        it 'data should have a role propertie'   { ($servers.role  | where {$_} ).count | Should -BeExactly $servers.count}
        it 'data should have an order propertie' { ($servers.order | where {$_} ).count | Should -BeExactly $servers.count}
    }
    context 'function check'{
        BeforeEach {
            mock start-sleep
            $null =  stop-xserver -servers $servers -lot $lot -wait 1
        }
        it 'should run start-sleep'{ Should -Invoke -CommandName start-sleep -Times 1}   
        it 'should throw when receiving empty data' { { stop-xserver -servers $server -lot $lot -wait 1 } | Should -Throw } 
        it 'should throw when receiving a string' { { stop-xserver -servers server1 -lot $lot -wait 1 } | Should -Throw }
        it 'should throw when server miss and order value' {
            $servers = [PSCustomObject]@{name = "SERVER1";lot  = 1;role = "web";order = ""}
            { stop-xserver -servers $servers -lot $lot -wait 1 } | Should -Throw
        } 
    }
    context 'script check'{
        BeforeEach {
            Mock start-sleep
            $null = foreach ($lot in (1..2)){stop-xserver -servers $servers -lot $lot -wait 1}
        }
        it 'should run start-sleep twice' {
            Should -Invoke -CommandName start-sleep -Times 2 -Exactly
        }
        it 'variable waitfor should exist'{
            get-variable waitfor | should -Be $true
        }
    }
}
Describe 'function get-numberoflots' {
    context 'basic check'{
        it 'should return an integer'{
            get-numberoflots -servers $servers | Should -BeOfType [int]
        }
        it 'should throw when not receiving a pscustomobject'{
            { get-numberoflots -servers toto } | Should -Throw
        }        
    }
}