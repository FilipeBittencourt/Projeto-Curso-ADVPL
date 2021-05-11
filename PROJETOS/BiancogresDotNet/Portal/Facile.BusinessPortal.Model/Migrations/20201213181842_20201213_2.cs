using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201213_2 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "DataMedicao",
                table: "SolicitacaoServicoItemMedicao",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ObservacaoMedicao",
                table: "SolicitacaoServicoItemMedicao",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "UsuarioID",
                table: "SolicitacaoServicoItemMedicao",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoItemMedicao_UsuarioID",
                table: "SolicitacaoServicoItemMedicao",
                column: "UsuarioID");

            migrationBuilder.AddForeignKey(
                name: "FK_SolicitacaoServicoItemMedicao_Usuario_UsuarioID",
                table: "SolicitacaoServicoItemMedicao",
                column: "UsuarioID",
                principalTable: "Usuario",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_SolicitacaoServicoItemMedicao_Usuario_UsuarioID",
                table: "SolicitacaoServicoItemMedicao");

            migrationBuilder.DropIndex(
                name: "IX_SolicitacaoServicoItemMedicao_UsuarioID",
                table: "SolicitacaoServicoItemMedicao");

            migrationBuilder.DropColumn(
                name: "DataMedicao",
                table: "SolicitacaoServicoItemMedicao");

            migrationBuilder.DropColumn(
                name: "ObservacaoMedicao",
                table: "SolicitacaoServicoItemMedicao");

            migrationBuilder.DropColumn(
                name: "UsuarioID",
                table: "SolicitacaoServicoItemMedicao");
        }
    }
}
