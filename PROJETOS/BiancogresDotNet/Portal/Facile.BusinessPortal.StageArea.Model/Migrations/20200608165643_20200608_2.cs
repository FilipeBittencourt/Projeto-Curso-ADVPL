using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _20200608_2 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "UnidadeProduto",
                table: "PedidoCompra",
                newName: "ProdutoUnidade");

            migrationBuilder.RenameColumn(
                name: "NomeProduto",
                table: "PedidoCompra",
                newName: "ProdutoNome");

            migrationBuilder.RenameColumn(
                name: "CodigoProduto",
                table: "PedidoCompra",
                newName: "ProdutoCodigo");

            migrationBuilder.AddColumn<string>(
                name: "PedidoItem",
                table: "PedidoCompra",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PedidoItem",
                table: "PedidoCompra");

            migrationBuilder.RenameColumn(
                name: "ProdutoUnidade",
                table: "PedidoCompra",
                newName: "UnidadeProduto");

            migrationBuilder.RenameColumn(
                name: "ProdutoNome",
                table: "PedidoCompra",
                newName: "NomeProduto");

            migrationBuilder.RenameColumn(
                name: "ProdutoCodigo",
                table: "PedidoCompra",
                newName: "CodigoProduto");
        }
    }
}
