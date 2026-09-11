function Read-DiaryApiKey {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $dialog = New-Object System.Windows.Forms.Form
    $dialog.Text = 'Dopa - OpenAI API key'
    $dialog.ClientSize = New-Object System.Drawing.Size(520, 185)
    $dialog.StartPosition = 'CenterScreen'
    $dialog.FormBorderStyle = 'FixedDialog'
    $dialog.MaximizeBox = $false
    $dialog.MinimizeBox = $false
    $label = New-Object System.Windows.Forms.Label
    $label.Text = 'Paste the full API key. Its value stays hidden.'
    $label.SetBounds(16, 16, 490, 24)
    $inputBox = New-Object System.Windows.Forms.TextBox
    $inputBox.UseSystemPasswordChar = $true
    $inputBox.MaxLength = 4096
    $inputBox.SetBounds(16, 48, 370, 28)
    $paste = New-Object System.Windows.Forms.Button
    $paste.Text = 'Paste'
    $paste.SetBounds(396, 46, 108, 30)
    $count = New-Object System.Windows.Forms.Label
    $count.SetBounds(16, 86, 490, 32)
    $save = New-Object System.Windows.Forms.Button
    $save.Text = 'Continue'
    $save.SetBounds(288, 135, 104, 32)
    $save.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $save.Enabled = $false
    $cancel = New-Object System.Windows.Forms.Button
    $cancel.Text = 'Cancel'
    $cancel.SetBounds(400, 135, 104, 32)
    $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $count.Text = '0 characters - paste your full key'
    $inputBox.Add_TextChanged({
        $candidateKey = $inputBox.Text.Trim()
        $count.Text = ('{0} characters (format check only)' -f $candidateKey.Length)
        $save.Enabled = $candidateKey -cmatch '^sk-\S{20,}$'
    })
    # Read the clipboard only after an explicit click, never print its contents.
    $paste.Add_Click({
        if ([System.Windows.Forms.Clipboard]::ContainsText()) {
            $inputBox.Text = [System.Windows.Forms.Clipboard]::GetText().Trim()
        }
    })
    $dialog.Controls.AddRange(@($label, $inputBox, $paste, $count, $save, $cancel))
    $dialog.AcceptButton = $save
    $dialog.CancelButton = $cancel
    try {
        if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
            throw 'Cancelled. No key was saved and the server was not stopped.'
        }
        $resultKey = $inputBox.Text.Trim()
        if ($resultKey -cnotmatch '^sk-\S{20,}$') { throw 'Invalid key format. Nothing was saved.' }
        return $resultKey
    } finally {
        $inputBox.Clear()
        $dialog.Dispose()
    }
}
