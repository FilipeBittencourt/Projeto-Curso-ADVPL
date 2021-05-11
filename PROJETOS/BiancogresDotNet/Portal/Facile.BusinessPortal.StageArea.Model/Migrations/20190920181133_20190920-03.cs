using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _2019092003 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Sacado_EmpresaID_UnidadeID_CPFCNPJ",
                table: "Sacado");

            migrationBuilder.AlterColumn<long>(
                name: "UnidadeID",
                table: "Sacado",
                nullable: true,
                oldClrType: typeof(long));

            migrationBuilder.AlterColumn<long>(
                name: "UnidadeID",
                table: "ProcessoEmpresa",
                nullable: true,
                oldClrType: typeof(long));

            migrationBuilder.AlterColumn<long>(
                name: "UnidadeID",
                table: "LogIntegracao",
                nullable: true,
                oldClrType: typeof(long));

            migrationBuilder.AlterColumn<long>(
                name: "UnidadeID",
                table: "EmpresaInterface",
                nullable: true,
                oldClrType: typeof(long));

            migrationBuilder.AlterColumn<long>(
                name: "UnidadeID",
                table: "Boleto",
                nullable: true,
                oldClrType: typeof(long));

            migrationBuilder.CreateIndex(
                name: "IX_Sacado_EmpresaID_UnidadeID_CPFCNPJ",
                table: "Sacado",
                columns: new[] { "EmpresaID", "UnidadeID", "CPFCNPJ" },
                unique: true,
                filter: "[UnidadeID] IS NOT NULL AND [CPFCNPJ] IS NOT NULL");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Sacado_EmpresaID_UnidadeID_CPFCNPJ",
                table: "Sacado");

            migrationBuilder.AlterColumn<long>(
                name: "UnidadeID",
                table: "Sacado",
                nullable: false,
                oldClrType: typeof(long),
                oldNullable: true);

            migrationBuilder.AlterColumn<long>(
                name: "UnidadeID",
                table: "ProcessoEmpresa",
                nullable: false,
                oldClrType: typeof(long),
                oldNullable: true);

            migrationBuilder.AlterColumn<long>(
                name: "UnidadeID",
                table: "LogIntegracao",
                nullable: false,
                oldClrType: typeof(long),
                oldNullable: true);

            migrationBuilder.AlterColumn<long>(
                name: "UnidadeID",
                table: "EmpresaInterface",
                nullable: false,
                oldClrType: typeof(long),
                oldNullable: true);

            migrationBuilder.AlterColumn<long>(
                name: "UnidadeID",
                table: "Boleto",
                nullable: false,
                oldClrType: typeof(long),
                oldNullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Sacado_EmpresaID_UnidadeID_CPFCNPJ",
                table: "Sacado",
                columns: new[] { "EmpresaID", "UnidadeID", "CPFCNPJ" },
                unique: true,
                filter: "[CPFCNPJ] IS NOT NULL");
        }
    }
}
