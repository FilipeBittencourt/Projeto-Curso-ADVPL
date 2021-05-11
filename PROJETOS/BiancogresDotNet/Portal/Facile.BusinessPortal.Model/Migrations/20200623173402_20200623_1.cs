using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20200623_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<long>(
                name: "LocalEntregaID",
                table: "NotaFiscalCompra",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Motorista",
                table: "NotaFiscalCompra",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Placa",
                table: "NotaFiscalCompra",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "TipoProdutoID",
                table: "NotaFiscalCompra",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "TipoVeiculoID",
                table: "NotaFiscalCompra",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_NotaFiscalCompra_LocalEntregaID",
                table: "NotaFiscalCompra",
                column: "LocalEntregaID");

            migrationBuilder.CreateIndex(
                name: "IX_NotaFiscalCompra_TipoProdutoID",
                table: "NotaFiscalCompra",
                column: "TipoProdutoID");

            migrationBuilder.CreateIndex(
                name: "IX_NotaFiscalCompra_TipoVeiculoID",
                table: "NotaFiscalCompra",
                column: "TipoVeiculoID");

            migrationBuilder.AddForeignKey(
                name: "FK_NotaFiscalCompra_LocalEntrega_LocalEntregaID",
                table: "NotaFiscalCompra",
                column: "LocalEntregaID",
                principalTable: "LocalEntrega",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_NotaFiscalCompra_TipoProduto_TipoProdutoID",
                table: "NotaFiscalCompra",
                column: "TipoProdutoID",
                principalTable: "TipoProduto",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_NotaFiscalCompra_TipoVeiculo_TipoVeiculoID",
                table: "NotaFiscalCompra",
                column: "TipoVeiculoID",
                principalTable: "TipoVeiculo",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_NotaFiscalCompra_LocalEntrega_LocalEntregaID",
                table: "NotaFiscalCompra");

            migrationBuilder.DropForeignKey(
                name: "FK_NotaFiscalCompra_TipoProduto_TipoProdutoID",
                table: "NotaFiscalCompra");

            migrationBuilder.DropForeignKey(
                name: "FK_NotaFiscalCompra_TipoVeiculo_TipoVeiculoID",
                table: "NotaFiscalCompra");

            migrationBuilder.DropIndex(
                name: "IX_NotaFiscalCompra_LocalEntregaID",
                table: "NotaFiscalCompra");

            migrationBuilder.DropIndex(
                name: "IX_NotaFiscalCompra_TipoProdutoID",
                table: "NotaFiscalCompra");

            migrationBuilder.DropIndex(
                name: "IX_NotaFiscalCompra_TipoVeiculoID",
                table: "NotaFiscalCompra");

            migrationBuilder.DropColumn(
                name: "LocalEntregaID",
                table: "NotaFiscalCompra");

            migrationBuilder.DropColumn(
                name: "Motorista",
                table: "NotaFiscalCompra");

            migrationBuilder.DropColumn(
                name: "Placa",
                table: "NotaFiscalCompra");

            migrationBuilder.DropColumn(
                name: "TipoProdutoID",
                table: "NotaFiscalCompra");

            migrationBuilder.DropColumn(
                name: "TipoVeiculoID",
                table: "NotaFiscalCompra");
        }
    }
}
