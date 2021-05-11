using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201213_3 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<byte[]>(
                name: "ArquivoAnexo",
                table: "SolicitacaoServicoItemMedicao",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DescricaoAnexo",
                table: "SolicitacaoServicoItemMedicao",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NomeAnexo",
                table: "SolicitacaoServicoItemMedicao",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "TipoAnexo",
                table: "SolicitacaoServicoItemMedicao",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ArquivoAnexo",
                table: "SolicitacaoServicoItemMedicao");

            migrationBuilder.DropColumn(
                name: "DescricaoAnexo",
                table: "SolicitacaoServicoItemMedicao");

            migrationBuilder.DropColumn(
                name: "NomeAnexo",
                table: "SolicitacaoServicoItemMedicao");

            migrationBuilder.DropColumn(
                name: "TipoAnexo",
                table: "SolicitacaoServicoItemMedicao");
        }
    }
}
