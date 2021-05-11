using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20190828_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "Parcela",
                table: "TituloPagar",
                nullable: false,
                oldClrType: typeof(int));

            migrationBuilder.AddColumn<string>(
                name: "ClasseIcone",
                table: "Modulo",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "AntecipacaoID",
                table: "AntecipacaoItem",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Contato",
                table: "Antecipacao",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataRecebimento",
                table: "Antecipacao",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<decimal>(
                name: "Taxa",
                table: "Antecipacao",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.CreateIndex(
                name: "IX_AntecipacaoItem_AntecipacaoID",
                table: "AntecipacaoItem",
                column: "AntecipacaoID");

            migrationBuilder.AddForeignKey(
                name: "FK_AntecipacaoItem_Antecipacao_AntecipacaoID",
                table: "AntecipacaoItem",
                column: "AntecipacaoID",
                principalTable: "Antecipacao",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AntecipacaoItem_Antecipacao_AntecipacaoID",
                table: "AntecipacaoItem");

            migrationBuilder.DropIndex(
                name: "IX_AntecipacaoItem_AntecipacaoID",
                table: "AntecipacaoItem");

            migrationBuilder.DropColumn(
                name: "ClasseIcone",
                table: "Modulo");

            migrationBuilder.DropColumn(
                name: "AntecipacaoID",
                table: "AntecipacaoItem");

            migrationBuilder.DropColumn(
                name: "Contato",
                table: "Antecipacao");

            migrationBuilder.DropColumn(
                name: "DataRecebimento",
                table: "Antecipacao");

            migrationBuilder.DropColumn(
                name: "Taxa",
                table: "Antecipacao");

            migrationBuilder.AlterColumn<int>(
                name: "Parcela",
                table: "TituloPagar",
                nullable: false,
                oldClrType: typeof(string));
        }
    }
}
