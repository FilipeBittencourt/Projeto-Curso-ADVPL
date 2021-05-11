using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201201_5 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "SolicitacaoServicoItemCotacao");

            migrationBuilder.CreateTable(
                name: "SolicitacaoServicoCotacao",
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
                    SolicitacaoServicoID = table.Column<long>(nullable: false),
                    FornecedorID = table.Column<long>(nullable: false),
                    DataValidade = table.Column<DateTime>(nullable: false),
                    NumeroOrcamento = table.Column<string>(nullable: true),
                    TipoFrete = table.Column<string>(nullable: true),
                    CondicaoPagamento = table.Column<string>(nullable: true),
                    Revisao = table.Column<string>(nullable: true),
                    AtendeCotacao = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SolicitacaoServicoCotacao", x => x.ID);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoCotacao_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoCotacao_Fornecedor_FornecedorID",
                        column: x => x.FornecedorID,
                        principalTable: "Fornecedor",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoCotacao_SolicitacaoServico_SolicitacaoServicoID",
                        column: x => x.SolicitacaoServicoID,
                        principalTable: "SolicitacaoServico",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoCotacao_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "SolicitacaoServicoCotacaoItem",
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
                    SolicitacaoServicoCotacaoID = table.Column<long>(nullable: false),
                    SolicitacaoServicoItemID = table.Column<long>(nullable: false),
                    Observacao = table.Column<string>(nullable: true),
                    CodigoProduto = table.Column<string>(nullable: true),
                    Preco = table.Column<decimal>(nullable: false),
                    IPI = table.Column<decimal>(nullable: false),
                    ValorSubstituicao = table.Column<decimal>(nullable: false),
                    PrazoEntrega = table.Column<int>(nullable: false),
                    Moeda = table.Column<string>(nullable: true),
                    Marca = table.Column<string>(nullable: true),
                    AtendeTotalmente = table.Column<int>(nullable: false),
                    AtendeItem = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SolicitacaoServicoCotacaoItem", x => x.ID);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoCotacaoItem_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoCotacaoItem_SolicitacaoServicoCotacao_SolicitacaoServicoCotacaoID",
                        column: x => x.SolicitacaoServicoCotacaoID,
                        principalTable: "SolicitacaoServicoCotacao",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoCotacaoItem_SolicitacaoServicoItem_SolicitacaoServicoItemID",
                        column: x => x.SolicitacaoServicoItemID,
                        principalTable: "SolicitacaoServicoItem",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoCotacaoItem_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoCotacao_EmpresaID",
                table: "SolicitacaoServicoCotacao",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoCotacao_FornecedorID",
                table: "SolicitacaoServicoCotacao",
                column: "FornecedorID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoCotacao_SolicitacaoServicoID",
                table: "SolicitacaoServicoCotacao",
                column: "SolicitacaoServicoID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoCotacao_UnidadeID",
                table: "SolicitacaoServicoCotacao",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoCotacaoItem_EmpresaID",
                table: "SolicitacaoServicoCotacaoItem",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoCotacaoItem_SolicitacaoServicoCotacaoID",
                table: "SolicitacaoServicoCotacaoItem",
                column: "SolicitacaoServicoCotacaoID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoCotacaoItem_SolicitacaoServicoItemID",
                table: "SolicitacaoServicoCotacaoItem",
                column: "SolicitacaoServicoItemID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoCotacaoItem_UnidadeID",
                table: "SolicitacaoServicoCotacaoItem",
                column: "UnidadeID");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "SolicitacaoServicoCotacaoItem");

            migrationBuilder.DropTable(
                name: "SolicitacaoServicoCotacao");

            migrationBuilder.CreateTable(
                name: "SolicitacaoServicoItemCotacao",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    AtendeItem = table.Column<int>(nullable: false),
                    AtendeTotalmente = table.Column<int>(nullable: false),
                    CodigoProduto = table.Column<string>(nullable: true),
                    DataHoraIntegracao = table.Column<DateTime>(nullable: true),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    EmpresaID = table.Column<long>(nullable: false),
                    FornecedorID = table.Column<long>(nullable: false),
                    Habilitado = table.Column<bool>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    IPI = table.Column<decimal>(nullable: false),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    InsertUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    Marca = table.Column<string>(nullable: true),
                    MensagemRetorno = table.Column<string>(nullable: true),
                    Moeda = table.Column<string>(nullable: true),
                    Observacao = table.Column<string>(nullable: true),
                    PrazoEntrega = table.Column<int>(nullable: false),
                    Preco = table.Column<decimal>(nullable: false),
                    Revisao = table.Column<string>(nullable: true),
                    SolicitacaoServicoItemID = table.Column<long>(nullable: false),
                    StageID = table.Column<long>(nullable: true),
                    StatusIntegracao = table.Column<int>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    ValorSubstituicao = table.Column<decimal>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SolicitacaoServicoItemCotacao", x => x.ID);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoItemCotacao_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoItemCotacao_Fornecedor_FornecedorID",
                        column: x => x.FornecedorID,
                        principalTable: "Fornecedor",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoItemCotacao_SolicitacaoServicoItem_SolicitacaoServicoItemID",
                        column: x => x.SolicitacaoServicoItemID,
                        principalTable: "SolicitacaoServicoItem",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoItemCotacao_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoItemCotacao_EmpresaID",
                table: "SolicitacaoServicoItemCotacao",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoItemCotacao_FornecedorID",
                table: "SolicitacaoServicoItemCotacao",
                column: "FornecedorID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoItemCotacao_SolicitacaoServicoItemID",
                table: "SolicitacaoServicoItemCotacao",
                column: "SolicitacaoServicoItemID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoItemCotacao_UnidadeID",
                table: "SolicitacaoServicoItemCotacao",
                column: "UnidadeID");
        }
    }
}
