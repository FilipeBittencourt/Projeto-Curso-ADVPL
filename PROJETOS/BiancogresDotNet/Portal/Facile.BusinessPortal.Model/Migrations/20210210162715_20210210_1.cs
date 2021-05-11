using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20210210_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<byte[]>(
                name: "ArquivoAnexo",
                table: "SolicitacaoServicoCotacao",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DescricaoAnexo",
                table: "SolicitacaoServicoCotacao",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NomeAnexo",
                table: "SolicitacaoServicoCotacao",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "TipoAnexo",
                table: "SolicitacaoServicoCotacao",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ArquivoAnexo",
                table: "SolicitacaoServicoCotacao");

            migrationBuilder.DropColumn(
                name: "DescricaoAnexo",
                table: "SolicitacaoServicoCotacao");

            migrationBuilder.DropColumn(
                name: "NomeAnexo",
                table: "SolicitacaoServicoCotacao");

            migrationBuilder.DropColumn(
                name: "TipoAnexo",
                table: "SolicitacaoServicoCotacao");
        }
    }
}
