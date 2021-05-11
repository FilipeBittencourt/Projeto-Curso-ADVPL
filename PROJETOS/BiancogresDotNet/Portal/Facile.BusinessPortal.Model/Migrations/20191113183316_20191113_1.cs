using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20191113_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            //migrationBuilder.DropForeignKey(
            //    name: "FK_AntecipacaoHistorico_Antecipacao_AntecipcaoID",
            //    table: "AntecipacaoHistorico");

            //migrationBuilder.RenameColumn(
            //    name: "AntecipcaoID",
            //    table: "AntecipacaoHistorico",
            //    newName: "AntecipacaoID");

            //migrationBuilder.RenameIndex(
            //    name: "IX_AntecipacaoHistorico_AntecipcaoID",
            //    table: "AntecipacaoHistorico",
            //    newName: "IX_AntecipacaoHistorico_AntecipacaoID");

            //migrationBuilder.AddForeignKey(
            //    name: "FK_AntecipacaoHistorico_Antecipacao_AntecipacaoID",
            //    table: "AntecipacaoHistorico",
            //    column: "AntecipacaoID",
            //    principalTable: "Antecipacao",
            //    principalColumn: "ID",
            //    onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AntecipacaoHistorico_Antecipacao_AntecipacaoID",
                table: "AntecipacaoHistorico");

            migrationBuilder.RenameColumn(
                name: "AntecipacaoID",
                table: "AntecipacaoHistorico",
                newName: "AntecipcaoID");

            migrationBuilder.RenameIndex(
                name: "IX_AntecipacaoHistorico_AntecipacaoID",
                table: "AntecipacaoHistorico",
                newName: "IX_AntecipacaoHistorico_AntecipcaoID");

            migrationBuilder.AddForeignKey(
                name: "FK_AntecipacaoHistorico_Antecipacao_AntecipcaoID",
                table: "AntecipacaoHistorico",
                column: "AntecipcaoID",
                principalTable: "Antecipacao",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
