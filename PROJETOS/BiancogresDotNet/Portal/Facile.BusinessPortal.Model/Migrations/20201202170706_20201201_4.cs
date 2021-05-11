using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201201_4 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<long>(
                name: "SetorAprovacaoID",
                table: "SolicitacaoServico",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServico_SetorAprovacaoID",
                table: "SolicitacaoServico",
                column: "SetorAprovacaoID");

            migrationBuilder.AddForeignKey(
                name: "FK_SolicitacaoServico_SetorAprovacao_SetorAprovacaoID",
                table: "SolicitacaoServico",
                column: "SetorAprovacaoID",
                principalTable: "SetorAprovacao",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_SolicitacaoServico_SetorAprovacao_SetorAprovacaoID",
                table: "SolicitacaoServico");

            migrationBuilder.DropIndex(
                name: "IX_SolicitacaoServico_SetorAprovacaoID",
                table: "SolicitacaoServico");

            migrationBuilder.DropColumn(
                name: "SetorAprovacaoID",
                table: "SolicitacaoServico");
        }
    }
}
