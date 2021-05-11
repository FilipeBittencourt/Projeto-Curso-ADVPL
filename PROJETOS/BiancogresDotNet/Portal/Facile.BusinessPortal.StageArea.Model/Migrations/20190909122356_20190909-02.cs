using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _2019090902 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "ChaveUnica",
                table: "Sacado",
                nullable: false,
                oldClrType: typeof(string),
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "ChaveUnica",
                table: "LogIntegracao",
                nullable: false,
                oldClrType: typeof(string),
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "ChaveUnica",
                table: "Boleto",
                nullable: false,
                oldClrType: typeof(string),
                oldNullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Sacado_EmpresaID_ChaveUnica",
                table: "Sacado",
                columns: new[] { "EmpresaID", "ChaveUnica" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Boleto_EmpresaID_ChaveUnica",
                table: "Boleto",
                columns: new[] { "EmpresaID", "ChaveUnica" },
                unique: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Sacado_EmpresaID_ChaveUnica",
                table: "Sacado");

            migrationBuilder.DropIndex(
                name: "IX_Boleto_EmpresaID_ChaveUnica",
                table: "Boleto");

            migrationBuilder.AlterColumn<string>(
                name: "ChaveUnica",
                table: "Sacado",
                nullable: true,
                oldClrType: typeof(string));

            migrationBuilder.AlterColumn<string>(
                name: "ChaveUnica",
                table: "LogIntegracao",
                nullable: true,
                oldClrType: typeof(string));

            migrationBuilder.AlterColumn<string>(
                name: "ChaveUnica",
                table: "Boleto",
                nullable: true,
                oldClrType: typeof(string));
        }
    }
}
