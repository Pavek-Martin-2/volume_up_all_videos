cls

# vsechny videa v adreasi budou mit zvuk podle zadani
Set-PSDebug -Strict
Remove-Variable files_all,files,aa,bb,filename,volba,pridat_zvuk  -ErrorAction SilentlyContinue
Remove-Variable pripona_up,soubor,soubor_nazev,soubor_pripona,poc,lvl -ErrorAction SilentlyContinue
Write-Host -ForegroundColor Cyan "zmeni hlasitost zvuku u vsech videi a aktualnim adresari, podle volby uzivatele"

#$pole_include = @("*.txt", "*.doc")
#$pole_include = @("*.fli","*.FLC") # toto nejni case senzitive ! ,"*. "
$pole_include = @("*.fli","*.FLC","*.mp4","*.avi","*.mpg") # toto nejni case senzitive ! ,"*. " FLC jako flc atd.

$files_all = @() # all = vcetne jiz prevedenich, bude se filttrovat !
$files_all += @(Get-ChildItem -Include $pole_include -Name) | Sort-Object

# filtovani jiz prevedenych a prepis vsrho do neveho pole
$d_files_all = $files_all.Length

# kontrola existence video souboru
if ( $d_files_all -eq 0 ){
Write-Warning "nanalezeny zadne video soubory" 
sleep 5
exit
}

$files = @()
for ( $aa = 0; $aa -le $d_files_all -1; $aa++ ) {
$filename = $files_all[$aa]

if ((
-not ($filename.Contains("_UP1024") -or # poradil Copilot "-not" se dava pouze jedeno na zacatku, tim se invertuje vse
$filename.Contains("_UP2048") -or 
$filename.Contains("_UP512") -or
$filename.Contains("_MUTE") # -vol 0
))) {
$files += $filename
# prepise do neveho pole, vsechny nalezene soubory v aktualnim adresari u ktery jeste neprobehla konverze zvuku
}

}

# Remove-Variable volba, pridat_zvuk, pripona_up -ErrorAction SilentlyContinue
$volba = Read-Host -Prompt "vyber hlasitost videi [m]ute, [5]12, [1]024, [2]048 "

switch ($volba) {
    "m" {
        echo "[m]ute" # m, M bere oboji ( tzn. neni CaseSensitive)
        $pridat_zvuk = "0" # nastavena hodnota volume na nula, cili mute (nejde uz pak nikdy vratit zpatky zvuk u videa)
        $pripona_up = "_MUTE" # to "MUTE" je kdyz je treba krasavice a nezajima vas ktomu zvuk (tak zabytecne to nak nervalo)
        break
    }
    "5" {
        echo "[5]12"
        $pridat_zvuk = "512"
        $pripona_up = "_UP512"
        break
    }
    "1" {
        echo "[1]024"
        $pridat_zvuk = "1024"
        $pripona_up = "_UP1024"
        break
    }
    "2" {
        echo "[2]048"
        $pridat_zvuk = "2048"
        $pripona_up = "_UP2048"
        break
    }
    default { # vse ostatni bude toto
        Write-Warning "Chyba zadani"
        sleep 5
        exit
    }
}
#echo $pridat_zvuk # -ErrorAction SilentlyContinue (nejde ale bude exit)
#echo $pripona_up


# nastaveni hodnoty verbose u vystupu ffmpeg, viz scrennshoty
$pole_lvl = @("quiet", "panic", "fatal", "error", "warning", "info", "verbose", "debug", "trace")
#                0        1        2        3        4          5        6         7        8
$lvl = $pole_lvl[2] # 4 bude asi optimalni (default=5)

$d_files = $files.Length

for ( $bb = 0 ; $bb -le $d_files -1; $bb++) {
$soubor = $files[$bb]
$soubor_nazev = $soubor.Substring(0,$soubor.Length -4)
$soubor_pripona = $soubor.Substring($soubor.Length -4, 4)
$poc = $bb + 1

Write-Host -ForegroundColor Green "zpracovavam video " -NoNewline
Write-Host -ForegroundColor Red  "$poc/$d_files"
sleep 2

# ffmpeg -i 01_vid.mp4 -vol 1024 -vcodec copy 01_vid_out.mp4 # VZOR

#ffmpeg "-i" "$soubor" "-vol" "$pridat_zvuk" "-vcodec" "$copy" "$soubor_nazev$pripona_up$soubor_pripona" FUNGUJE TAKHLE !
#ffmpeg "-n" "-i" "$soubor" "-vol" "$pridat_zvuk" "-vcodec" "$cp" "$soubor_nazev$pripona_up$soubor_pripona"

#ffmpeg "-i" "$soubor" "-vol" "$pridat_zvuk" "-vcodec" "$cp" "$soubor_nazev$pripona_up$soubor_pripona" "-n"
#ffmpeg "-i" "$soubor" "-vol" "$pridat_zvuk" "-vcodec" "$cp" "$soubor_nazev$pripona_up$soubor_pripona" "-n"

#& ffmpeg -loglevel $lvl -i $video_input -filter:v "crop=iw:ih/2:0:0" $prefix_name_output"horni_pulka.mp4" -y
& ffmpeg -loglevel $lvl -i $soubor -vol $pridat_zvuk -vcodec "copy" $soubor_nazev$pripona_up$soubor_pripona -n
# -codec copy ( nebude vubec sahat do video stopy jenom ji ciste zkopiruje do cile, asi 20x rychlejsi nez bez toho ! )
# ffmpeg umi pracovat ve video souboru zvast z audio stopou a vzlast z video stopou, paklize se mu "nerekne" nic
# zpracovana oboji najednou, coz je vromo pripade zbytecne a mnohonasobne pomalejsi
# parametr "-n" na konci = neprepisuj znova jiz jednou prevedene 

}

Write-Host -ForegroundColor Yellow "Vse hotovo"
sleep 10

