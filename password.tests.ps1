
BeforeAll {
    . $psscriptroot\password.ps1
}

Describe 'function export-password ' {

    context 'testing path' {
        BeforeEach {
            mock out-file
            $null = export-password -password toto -path "C:\truc"
        }
        it 'should call out-file' {
            Should -Invoke -CommandName out-file
        }
    }

}