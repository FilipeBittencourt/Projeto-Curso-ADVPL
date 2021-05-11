using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _20200309_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_TituloPagar_EmpresaID_ChaveUnica",
                table: "TituloPagar");

            migrationBuilder.CreateIndex(
                name: "IX_TituloPagar_EmpresaID_ChaveUnica_Deletado",
                table: "TituloPagar",
                columns: new[] { "EmpresaID", "ChaveUnica", "Deletado" },
                unique: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_TituloPagar_EmpresaID_ChaveUnica_Deletado",
                table: "TituloPagar");

            migrationBuilder.CreateIndex(
                name: "IX_TituloPagar_EmpresaID_ChaveUnica",
                table: "TituloPagar",
                columns: new[] { "EmpresaID", "ChaveUnica" },
                unique: true);
        }
    }
}
