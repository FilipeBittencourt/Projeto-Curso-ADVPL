using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _20191004_3 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Fornecedor_EmpresaID_UnidadeID_CPFCNPJ",
                table: "Fornecedor");

            migrationBuilder.AlterColumn<string>(
                name: "CPFCNPJ",
                table: "Fornecedor",
                nullable: true,
                oldClrType: typeof(string),
                oldNullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "CPFCNPJ",
                table: "Fornecedor",
                nullable: true,
                oldClrType: typeof(string),
                oldNullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Fornecedor_EmpresaID_UnidadeID_CPFCNPJ",
                table: "Fornecedor",
                columns: new[] { "EmpresaID", "UnidadeID", "CPFCNPJ" },
                unique: true,
                filter: "[UnidadeID] IS NOT NULL AND [CPFCNPJ] IS NOT NULL");
        }
    }
}
