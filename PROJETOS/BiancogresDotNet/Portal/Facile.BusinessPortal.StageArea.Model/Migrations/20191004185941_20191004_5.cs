using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _20191004_5 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DataEmissaoDocumentoPagar",
                table: "TituloPagar");

            migrationBuilder.DropColumn(
                name: "DataEmissaoFaturaPagamento",
                table: "TituloPagar");

            migrationBuilder.DropColumn(
                name: "NumeroDocumentoPagar",
                table: "TituloPagar");

            migrationBuilder.DropColumn(
                name: "NumeroFaturaPagamento",
                table: "TituloPagar");

            migrationBuilder.DropColumn(
                name: "SerieDocumentoPagar",
                table: "TituloPagar");

            migrationBuilder.RenameColumn(
                name: "SerieFaturaPagamento",
                table: "TituloPagar",
                newName: "Serie");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "Serie",
                table: "TituloPagar",
                newName: "SerieFaturaPagamento");

            migrationBuilder.AddColumn<DateTime>(
                name: "DataEmissaoDocumentoPagar",
                table: "TituloPagar",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "DataEmissaoFaturaPagamento",
                table: "TituloPagar",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<string>(
                name: "NumeroDocumentoPagar",
                table: "TituloPagar",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NumeroFaturaPagamento",
                table: "TituloPagar",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "SerieDocumentoPagar",
                table: "TituloPagar",
                nullable: true);
        }
    }
}
