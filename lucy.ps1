# Définir le chemin du dossier racine contenant les dossiers des salons
$cheminDossier = "dossier\package\message"
# Définir les mots-clés à rechercher (ajoutez autant de mots-clés que nécessaire)
$motsCles = @("motclef", "abc", "def," "ghi", "ijk")
# Définir le chemin du fichier de sortie
$cheminFichierSortie = "dossier\resultats.txt"

# Initialiser les compteurs
$nombreFichiersTraites = 0
$nombreOccurrencesTrouvees = 0

# Créer ou vider le fichier de sortie s'il existe déjà
"" | Out-File $cheminFichierSortie

# Trouver tous les dossiers de salons dans le dossier racine
$dossiers = Get-ChildItem -Path $cheminDossier -Directory

foreach ($dossier in $dossiers) {
    $cheminFichierJson = Join-Path -Path $dossier.FullName -ChildPath "messages.json"
    if (Test-Path $cheminFichierJson) {
        $nombreFichiersTraites++
        $messages = Get-Content -Path $cheminFichierJson | ConvertFrom-Json
        $idsTrouves = @()
        foreach ($message in $messages) {
            foreach ($motCle in $motsCles) {
                if ($message.Contents -match "(?i)$motCle") {
                    $nombreOccurrencesTrouvees++
                    $idsTrouves += $message.ID
                    break # Stop la recherche pour ce message dès qu'un mot-clé est trouvé
                }
            }
        }
        if ($idsTrouves.Count -gt 0) {
            $idSalon = $dossier.Name.TrimStart('c')
            # Afficher l'ID du canal suivi des IDs des messages trouvés, séparés par des virgules
            $ligneResultat = "${idSalon}:`n" + ($idsTrouves -join ", ") + "`n`n"
            $ligneResultat | Out-File -FilePath $cheminFichierSortie -Append
        }
    }
}

# Afficher le résumé de l'exécution du script
Write-Host "La recherche est terminée."
Write-Host "$nombreFichiersTraites fichiers 'messages.json' ont été examinés."
Write-Host "$nombreOccurrencesTrouvees occurrences des mots-clés ont été trouvées."
Write-Host "Les résultats sont sauvegardés dans $cheminFichierSortie"
