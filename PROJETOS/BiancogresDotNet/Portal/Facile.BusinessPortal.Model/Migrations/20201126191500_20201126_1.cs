using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201126_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_SolicitacaoServico_Produto_ClasseValorID",
                table: "SolicitacaoServico");

            migrationBuilder.AddForeignKey(
                name: "FK_SolicitacaoServico_ClasseValor_ClasseValorID",
                table: "SolicitacaoServico",
                column: "ClasseValorID",
                principalTable: "ClasseValor",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_SolicitacaoServico_ClasseValor_ClasseValorID",
                table: "SolicitacaoServico");

            migrationBuilder.AddForeignKey(
                name: "FK_SolicitacaoServico_Produto_ClasseValorID",
                table: "SolicitacaoServico",
                column: "ClasseValorID",
                principalTable: "Produto",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
