using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201216_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "Item",
                table: "SolicitacaoServicoItem",
                newName: "PedidoItem");

            migrationBuilder.RenameColumn(
                name: "ContratoPedido",
                table: "SolicitacaoServicoItem",
                newName: "Pedido");

            migrationBuilder.AddColumn<string>(
                name: "Contrato",
                table: "SolicitacaoServicoItem",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ContratoItem",
                table: "SolicitacaoServicoItem",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "UsuarioID",
                table: "SolicitacaoServico",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServico_UsuarioID",
                table: "SolicitacaoServico",
                column: "UsuarioID");

            migrationBuilder.AddForeignKey(
                name: "FK_SolicitacaoServico_Usuario_UsuarioID",
                table: "SolicitacaoServico",
                column: "UsuarioID",
                principalTable: "Usuario",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_SolicitacaoServico_Usuario_UsuarioID",
                table: "SolicitacaoServico");

            migrationBuilder.DropIndex(
                name: "IX_SolicitacaoServico_UsuarioID",
                table: "SolicitacaoServico");

            migrationBuilder.DropColumn(
                name: "Contrato",
                table: "SolicitacaoServicoItem");

            migrationBuilder.DropColumn(
                name: "ContratoItem",
                table: "SolicitacaoServicoItem");

            migrationBuilder.DropColumn(
                name: "UsuarioID",
                table: "SolicitacaoServico");

            migrationBuilder.RenameColumn(
                name: "PedidoItem",
                table: "SolicitacaoServicoItem",
                newName: "Item");

            migrationBuilder.RenameColumn(
                name: "Pedido",
                table: "SolicitacaoServicoItem",
                newName: "ContratoPedido");
        }
    }
}
