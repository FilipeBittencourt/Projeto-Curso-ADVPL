using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201124_3 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Aprovado",
                table: "SolicitacaoServicoItemCotacao");

            migrationBuilder.DropColumn(
                name: "ArquivoAnexo",
                table: "SolicitacaoServicoFornecedor");

            migrationBuilder.DropColumn(
                name: "DescricaoAnexo",
                table: "SolicitacaoServicoFornecedor");

            migrationBuilder.DropColumn(
                name: "NomeAnexo",
                table: "SolicitacaoServicoFornecedor");

            migrationBuilder.DropColumn(
                name: "TipoAnexo",
                table: "SolicitacaoServicoFornecedor");

            migrationBuilder.AddColumn<bool>(
                name: "Aprovado",
                table: "SolicitacaoServicoFornecedor",
                nullable: false,
                defaultValue: false);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Aprovado",
                table: "SolicitacaoServicoFornecedor");

            migrationBuilder.AddColumn<bool>(
                name: "Aprovado",
                table: "SolicitacaoServicoItemCotacao",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<byte[]>(
                name: "ArquivoAnexo",
                table: "SolicitacaoServicoFornecedor",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DescricaoAnexo",
                table: "SolicitacaoServicoFornecedor",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NomeAnexo",
                table: "SolicitacaoServicoFornecedor",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "TipoAnexo",
                table: "SolicitacaoServicoFornecedor",
                nullable: true);
        }
    }
}
