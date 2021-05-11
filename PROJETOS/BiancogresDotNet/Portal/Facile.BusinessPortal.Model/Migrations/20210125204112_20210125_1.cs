using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20210125_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<long>(
                name: "UsuarioMedicaoID",
                table: "SolicitacaoServico",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "UsuarioOrigemID",
                table: "SolicitacaoServico",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServico_UsuarioMedicaoID",
                table: "SolicitacaoServico",
                column: "UsuarioMedicaoID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServico_UsuarioOrigemID",
                table: "SolicitacaoServico",
                column: "UsuarioOrigemID");

            migrationBuilder.AddForeignKey(
                name: "FK_SolicitacaoServico_Usuario_UsuarioMedicaoID",
                table: "SolicitacaoServico",
                column: "UsuarioMedicaoID",
                principalTable: "Usuario",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_SolicitacaoServico_Usuario_UsuarioOrigemID",
                table: "SolicitacaoServico",
                column: "UsuarioOrigemID",
                principalTable: "Usuario",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_SolicitacaoServico_Usuario_UsuarioMedicaoID",
                table: "SolicitacaoServico");

            migrationBuilder.DropForeignKey(
                name: "FK_SolicitacaoServico_Usuario_UsuarioOrigemID",
                table: "SolicitacaoServico");

            migrationBuilder.DropIndex(
                name: "IX_SolicitacaoServico_UsuarioMedicaoID",
                table: "SolicitacaoServico");

            migrationBuilder.DropIndex(
                name: "IX_SolicitacaoServico_UsuarioOrigemID",
                table: "SolicitacaoServico");

            migrationBuilder.DropColumn(
                name: "UsuarioMedicaoID",
                table: "SolicitacaoServico");

            migrationBuilder.DropColumn(
                name: "UsuarioOrigemID",
                table: "SolicitacaoServico");
        }
    }
}
