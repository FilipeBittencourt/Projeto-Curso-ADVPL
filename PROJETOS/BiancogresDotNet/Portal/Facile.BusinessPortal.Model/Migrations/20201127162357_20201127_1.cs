using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201127_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_SolicitacaoServicoItem_Unidade_UnidadeID",
                table: "SolicitacaoServicoItem");

            migrationBuilder.DropIndex(
                name: "IX_SolicitacaoServicoItem_UnidadeID",
                table: "SolicitacaoServicoItem");

            migrationBuilder.AddColumn<string>(
                name: "Unidade",
                table: "SolicitacaoServicoItem",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "UnidadeMedicao",
                table: "SolicitacaoServicoItem",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Unidade",
                table: "SolicitacaoServicoItem");

            migrationBuilder.DropColumn(
                name: "UnidadeMedicao",
                table: "SolicitacaoServicoItem");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoItem_UnidadeID",
                table: "SolicitacaoServicoItem",
                column: "UnidadeID");

            migrationBuilder.AddForeignKey(
                name: "FK_SolicitacaoServicoItem_Unidade_UnidadeID",
                table: "SolicitacaoServicoItem",
                column: "UnidadeID",
                principalTable: "Unidade",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
