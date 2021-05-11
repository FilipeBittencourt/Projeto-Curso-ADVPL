using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201230_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "DataFinalContrato",
                table: "SolicitacaoServicoItem",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "DataInicioContrato",
                table: "SolicitacaoServicoItem",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "RazaoSocial",
                table: "Fornecedor",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DataFinalContrato",
                table: "SolicitacaoServicoItem");

            migrationBuilder.DropColumn(
                name: "DataInicioContrato",
                table: "SolicitacaoServicoItem");

            migrationBuilder.DropColumn(
                name: "RazaoSocial",
                table: "Fornecedor");
        }
    }
}
