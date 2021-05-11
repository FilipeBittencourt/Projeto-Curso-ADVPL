using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201214_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "ValorMedicaoRestante",
                table: "SolicitacaoServicoItemMedicao",
                newName: "ValorServico");

            migrationBuilder.RenameColumn(
                name: "ValorMedicao",
                table: "SolicitacaoServicoItemMedicao",
                newName: "SaldoMedicao");

            migrationBuilder.RenameColumn(
                name: "DescricaoAnexo",
                table: "SolicitacaoServicoItemMedicao",
                newName: "TipoAnexoNotaFiscal");

            migrationBuilder.AddColumn<byte[]>(
                name: "ArquivoAnexoNotaFiscal",
                table: "SolicitacaoServicoItemMedicao",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "Medicao",
                table: "SolicitacaoServicoItemMedicao",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<string>(
                name: "NomeAnexoNotaFiscal",
                table: "SolicitacaoServicoItemMedicao",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Observacao",
                table: "SolicitacaoServicoItemMedicao",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ObservacaoNotaFiscal",
                table: "SolicitacaoServicoItemMedicao",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ArquivoAnexoNotaFiscal",
                table: "SolicitacaoServicoItemMedicao");

            migrationBuilder.DropColumn(
                name: "Medicao",
                table: "SolicitacaoServicoItemMedicao");

            migrationBuilder.DropColumn(
                name: "NomeAnexoNotaFiscal",
                table: "SolicitacaoServicoItemMedicao");

            migrationBuilder.DropColumn(
                name: "Observacao",
                table: "SolicitacaoServicoItemMedicao");

            migrationBuilder.DropColumn(
                name: "ObservacaoNotaFiscal",
                table: "SolicitacaoServicoItemMedicao");

            migrationBuilder.RenameColumn(
                name: "ValorServico",
                table: "SolicitacaoServicoItemMedicao",
                newName: "ValorMedicaoRestante");

            migrationBuilder.RenameColumn(
                name: "TipoAnexoNotaFiscal",
                table: "SolicitacaoServicoItemMedicao",
                newName: "DescricaoAnexo");

            migrationBuilder.RenameColumn(
                name: "SaldoMedicao",
                table: "SolicitacaoServicoItemMedicao",
                newName: "ValorMedicao");
        }
    }
}
