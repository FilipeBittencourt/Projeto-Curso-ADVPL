using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20200609_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Transportadora",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    StatusIntegracao = table.Column<int>(nullable: false),
                    DataHoraIntegracao = table.Column<DateTime>(nullable: true),
                    MensagemRetorno = table.Column<string>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    StageID = table.Column<long>(nullable: true),
                    CPFCNPJ = table.Column<string>(nullable: false),
                    Nome = table.Column<string>(nullable: false),
                    Email = table.Column<string>(nullable: true),
                    EmailWorkflow = table.Column<string>(nullable: true),
                    Observacoes = table.Column<string>(nullable: true),
                    CodigoERP = table.Column<string>(nullable: true),
                    CEP = table.Column<string>(nullable: false),
                    Logradouro = table.Column<string>(nullable: false),
                    Numero = table.Column<string>(nullable: true),
                    Complemento = table.Column<string>(nullable: true),
                    Bairro = table.Column<string>(nullable: true),
                    UF = table.Column<string>(nullable: false),
                    Cidade = table.Column<string>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Transportadora", x => x.ID);
                    table.ForeignKey(
                        name: "FK_Transportadora_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Transportadora_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "PedidoCompra",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    StatusIntegracao = table.Column<int>(nullable: false),
                    DataHoraIntegracao = table.Column<DateTime>(nullable: true),
                    MensagemRetorno = table.Column<string>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    StageID = table.Column<long>(nullable: true),
                    FornecedorID = table.Column<long>(nullable: false),
                    TransportadoraID = table.Column<long>(nullable: true),
                    DataEntrega = table.Column<DateTime>(nullable: false),
                    Pedido = table.Column<string>(nullable: true),
                    NomeProduto = table.Column<string>(nullable: true),
                    CodigoProduto = table.Column<string>(nullable: true),
                    UnidadeProduto = table.Column<string>(nullable: true),
                    Quantidade = table.Column<decimal>(nullable: false),
                    Saldo = table.Column<decimal>(nullable: false),
                    NumeroControleParticipante = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PedidoCompra", x => x.ID);
                    table.ForeignKey(
                        name: "FK_PedidoCompra_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PedidoCompra_Fornecedor_FornecedorID",
                        column: x => x.FornecedorID,
                        principalTable: "Fornecedor",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PedidoCompra_Transportadora_TransportadoraID",
                        column: x => x.TransportadoraID,
                        principalTable: "Transportadora",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PedidoCompra_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "NotaFiscal",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    StatusIntegracao = table.Column<int>(nullable: false),
                    DataHoraIntegracao = table.Column<DateTime>(nullable: true),
                    MensagemRetorno = table.Column<string>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    StageID = table.Column<long>(nullable: true),
                    FornecedorID = table.Column<long>(nullable: false),
                    TransportadoraID = table.Column<long>(nullable: true),
                    PedidoCompraID = table.Column<long>(nullable: false),
                    Numero = table.Column<string>(nullable: true),
                    Serie = table.Column<string>(nullable: true),
                    DataEmissao = table.Column<DateTime>(nullable: false),
                    NomeProduto = table.Column<string>(nullable: true),
                    CodigoProduto = table.Column<string>(nullable: true),
                    UnidadeProduto = table.Column<string>(nullable: true),
                    Quantidade = table.Column<decimal>(nullable: false),
                    Valor = table.Column<decimal>(nullable: false),
                    NumeroControleParticipante = table.Column<string>(nullable: true),
                    DataRecebimento = table.Column<DateTime>(nullable: false),
                    DataAgendamento = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_NotaFiscal", x => x.ID);
                    table.ForeignKey(
                        name: "FK_NotaFiscal_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_NotaFiscal_Fornecedor_FornecedorID",
                        column: x => x.FornecedorID,
                        principalTable: "Fornecedor",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_NotaFiscal_PedidoCompra_PedidoCompraID",
                        column: x => x.PedidoCompraID,
                        principalTable: "PedidoCompra",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_NotaFiscal_Transportadora_TransportadoraID",
                        column: x => x.TransportadoraID,
                        principalTable: "Transportadora",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_NotaFiscal_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_NotaFiscal_EmpresaID",
                table: "NotaFiscal",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_NotaFiscal_FornecedorID",
                table: "NotaFiscal",
                column: "FornecedorID");

            migrationBuilder.CreateIndex(
                name: "IX_NotaFiscal_PedidoCompraID",
                table: "NotaFiscal",
                column: "PedidoCompraID");

            migrationBuilder.CreateIndex(
                name: "IX_NotaFiscal_TransportadoraID",
                table: "NotaFiscal",
                column: "TransportadoraID");

            migrationBuilder.CreateIndex(
                name: "IX_NotaFiscal_UnidadeID",
                table: "NotaFiscal",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_PedidoCompra_EmpresaID",
                table: "PedidoCompra",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_PedidoCompra_FornecedorID",
                table: "PedidoCompra",
                column: "FornecedorID");

            migrationBuilder.CreateIndex(
                name: "IX_PedidoCompra_TransportadoraID",
                table: "PedidoCompra",
                column: "TransportadoraID");

            migrationBuilder.CreateIndex(
                name: "IX_PedidoCompra_UnidadeID",
                table: "PedidoCompra",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_Transportadora_EmpresaID",
                table: "Transportadora",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_Transportadora_UnidadeID",
                table: "Transportadora",
                column: "UnidadeID");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "NotaFiscal");

            migrationBuilder.DropTable(
                name: "PedidoCompra");

            migrationBuilder.DropTable(
                name: "Transportadora");
        }
    }
}
