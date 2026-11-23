using System;
using System.Diagnostics;
using System.Net.Http;
using System.Threading;
using System.Windows.Forms;

internal static class Inicializador
{
    [STAThread]
    private static void Main()
    {
        string pasta = AppContext.BaseDirectory;
        string arquivoBat = System.IO.Path.Combine(pasta, "ABRIR_PAINEL.bat");
        if (!System.IO.File.Exists(arquivoBat))
        {
            MessageBox.Show("Nao encontrei ABRIR_PAINEL.bat na pasta do aplicativo.",
                "Recursos Hidricos", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return;
        }

        try
        {
            Process.Start(new ProcessStartInfo(arquivoBat)
            {
                WorkingDirectory = pasta,
                UseShellExecute = true
            });

            using var cliente = new HttpClient { Timeout = TimeSpan.FromSeconds(1) };
            for (int tentativa = 0; tentativa < 120; tentativa++)
            {
                try
                {
                    using var resposta = cliente.GetAsync("http://127.0.0.1:8501").GetAwaiter().GetResult();
                    Process.Start(new ProcessStartInfo("http://127.0.0.1:8501")
                    {
                        UseShellExecute = true
                    });
                    return;
                }
                catch
                {
                    Thread.Sleep(500);
                }
            }

            MessageBox.Show("O painel nao iniciou. Confira a janela do ABRIR_PAINEL.bat.",
                "Recursos Hidricos", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
        catch (Exception erro)
        {
            MessageBox.Show("Nao foi possivel iniciar o painel:\n" + erro.Message,
                "Recursos Hidricos", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }
}
