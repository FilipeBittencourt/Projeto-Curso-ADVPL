using System;
using System.Collections.Generic;
using System.Text;

namespace Facile.BusinessPortal.Library.Structs.Interna
{
    public struct BoletoPDF
    {
        public Byte[] Pdf { get; set; }
        public string FileName { get; set; }
        public string FilePath { get; set; }
        public string FileNameZip { get; set; }
    }
}
