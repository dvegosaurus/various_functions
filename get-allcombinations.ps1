function get-allcombinations {
    param(
        $lists,
        $index = 0,
        [array]$string,
        $delimiter = "-"
    )

    foreach ($item in $lists[$index]){
        $currentstring = $string
        $currentstring += $item 

        if ($lists[($index+1)]){
            get-allcombinations $lists ($index+1) $currentstring
        }
        else {$currentstring -join $delimiter}
    }
}

$lists = 
("a","b","c"),
("1",2,3),
("toto","tata")
get-allcombinations $lists
