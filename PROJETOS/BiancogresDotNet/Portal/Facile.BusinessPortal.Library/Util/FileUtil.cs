using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace Facile.BusinessPortal.Library
{
    public class FileUtil
    {
        public static bool IsFileLocked(FileInfo file)
        {
            FileStream stream = null;

            try
            {
                stream = file.Open(FileMode.Open, FileAccess.Read, FileShare.None);
            }
            catch (IOException)
            {
                //the file is unavailable because it is:
                //still being written to
                //or being processed by another thread
                //or does not exist (has already been processed)
                return true;
            }
            finally
            {
                if (stream != null)
                    stream.Close();
            }

            //file is not locked
            return false;
        }

        public static bool TryDelete(string path)
        {
            if (File.Exists(path))
            {
                try
                {
                    var info = new FileInfo(path);
                    if (!IsFileLocked(info))
                        File.Delete(path);
                    return true;
                }
                catch
                {
                    return false;
                }
            }
            else
                return false;
        }
        public static void GravaLog(string mensagem)
        {
            if (!Directory.Exists(AppContext.BaseDirectory + "\\LOGS"))
            {
                Directory.CreateDirectory(AppContext.BaseDirectory + "\\LOGS");
            }

            var pathlog = AppContext.BaseDirectory + @"\LOGS\consoleapp.log";
            if (File.Exists(pathlog))
            {
                var info = new FileInfo(pathlog);
                if (info.Length > 1000000)
                {
                    FileUtil.BackupAndDelete(pathlog);
                }
            }
            try
            {
                StreamWriter writer = new StreamWriter(pathlog, true);
                writer.WriteLine(mensagem);
                writer.Close();
            } catch(Exception ex)
            {

            }
        }

        public static void BackupAndDelete(string path)
        {
            if (File.Exists(path))
            {
                try
                {
                    var info = new FileInfo(path);
                    if (!IsFileLocked(info))
                    {
                        var filename = Path.GetFileNameWithoutExtension(path);
                        var ext = Path.GetExtension(path);
                        var directory = Path.GetDirectoryName(path);
                        var bkppath = directory + "\\" +
                            filename + "." + DateTime.Now.Year.ToString().PadLeft(4, '0') +
                            DateTime.Now.Month.ToString().PadLeft(4, '0') +
                            DateTime.Now.Day.ToString().PadLeft(4, '0') +
                            DateTime.Now.ToLongTimeString().Replace(":", "") +
                            ext;

                        Console.WriteLine("CRIANDO BACKUP LOG: " + bkppath);

                        File.Move(path, bkppath);
                        TryDelete(path);
                    }
                }
                catch (IOException ex)
                {
                    Console.WriteLine("ERRO (IO) CRIANDO BACKUP LOG: " + ex.Message);
                }
                catch (Exception ex)
                {
                    Console.WriteLine("ERRO CRIANDO BACKUP LOG: " + ex.Message);
                }
            }
        }
    }
}
