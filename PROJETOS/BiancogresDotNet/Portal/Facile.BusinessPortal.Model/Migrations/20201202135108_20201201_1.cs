using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201201_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "Unidade",
                table: "SolicitacaoServicoItem",
                newName: "UnidadeMedida");

            migrationBuilder.AddColumn<long>(
                name: "ContaContabilID",
                table: "SolicitacaoServicoItem",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.AddColumn<long>(
                name: "ItemContaID",
                table: "SolicitacaoServico",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.AddColumn<long>(
                name: "SubItemContaID",
                table: "SolicitacaoServico",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.AddColumn<string>(
                name: "UnidadeMedida",
                table: "Produto",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "ContaContabil",
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
                    Codigo = table.Column<string>(nullable: true),
                    Descricao = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ContaContabil", x => x.ID);
                    table.ForeignKey(
                        name: "FK_ContaContabil_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ContaContabil_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ItemConta",
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
                    Codigo = table.Column<string>(nullable: true),
                    Descricao = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ItemConta", x => x.ID);
                    table.ForeignKey(
                        name: "FK_ItemConta_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ItemConta_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "SubItemConta",
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
                    Codigo = table.Column<string>(nullable: true),
                    Descricao = table.Column<string>(nullable: true),
                    ClasseValorID = table.Column<long>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SubItemConta", x => x.ID);
                    table.ForeignKey(
                        name: "FK_SubItemConta_ClasseValor_ClasseValorID",
                        column: x => x.ClasseValorID,
                        principalTable: "ClasseValor",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SubItemConta_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SubItemConta_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoItem_ContaContabilID",
                table: "SolicitacaoServicoItem",
                column: "ContaContabilID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoItem_UnidadeID",
                table: "SolicitacaoServicoItem",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServico_ItemContaID",
                table: "SolicitacaoServico",
                column: "ItemContaID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServico_SubItemContaID",
                table: "SolicitacaoServico",
                column: "SubItemContaID");

            migrationBuilder.CreateIndex(
                name: "IX_ContaContabil_EmpresaID",
                table: "ContaContabil",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_ContaContabil_UnidadeID",
                table: "ContaContabil",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_ItemConta_EmpresaID",
                table: "ItemConta",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_ItemConta_UnidadeID",
                table: "ItemConta",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_SubItemConta_ClasseValorID",
                table: "SubItemConta",
                column: "ClasseValorID");

            migrationBuilder.CreateIndex(
                name: "IX_SubItemConta_EmpresaID",
                table: "SubItemConta",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_SubItemConta_UnidadeID",
                table: "SubItemConta",
                column: "UnidadeID");

            migrationBuilder.AddForeignKey(
                name: "FK_SolicitacaoServico_ItemConta_ItemContaID",
                table: "SolicitacaoServico",
                column: "ItemContaID",
                principalTable: "ItemConta",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_SolicitacaoServico_SubItemConta_SubItemContaID",
                table: "SolicitacaoServico",
                column: "SubItemContaID",
                principalTable: "SubItemConta",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_SolicitacaoServicoItem_ContaContabil_ContaContabilID",
                table: "SolicitacaoServicoItem",
                column: "ContaContabilID",
                principalTable: "ContaContabil",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_SolicitacaoServicoItem_Unidade_UnidadeID",
                table: "SolicitacaoServicoItem",
                column: "UnidadeID",
                principalTable: "Unidade",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_SolicitacaoServico_ItemConta_ItemContaID",
                table: "SolicitacaoServico");

            migrationBuilder.DropForeignKey(
                name: "FK_SolicitacaoServico_SubItemConta_SubItemContaID",
                table: "SolicitacaoServico");

            migrationBuilder.DropForeignKey(
                name: "FK_SolicitacaoServicoItem_ContaContabil_ContaContabilID",
                table: "SolicitacaoServicoItem");

            migrationBuilder.DropForeignKey(
                name: "FK_SolicitacaoServicoItem_Unidade_UnidadeID",
                table: "SolicitacaoServicoItem");

            migrationBuilder.DropTable(
                name: "ContaContabil");

            migrationBuilder.DropTable(
                name: "ItemConta");

            migrationBuilder.DropTable(
                name: "SubItemConta");

            migrationBuilder.DropIndex(
                name: "IX_SolicitacaoServicoItem_ContaContabilID",
                table: "SolicitacaoServicoItem");

            migrationBuilder.DropIndex(
                name: "IX_SolicitacaoServicoItem_UnidadeID",
                table: "SolicitacaoServicoItem");

            migrationBuilder.DropIndex(
                name: "IX_SolicitacaoServico_ItemContaID",
                table: "SolicitacaoServico");

            migrationBuilder.DropIndex(
                name: "IX_SolicitacaoServico_SubItemContaID",
                table: "SolicitacaoServico");

            migrationBuilder.DropColumn(
                name: "ContaContabilID",
                table: "SolicitacaoServicoItem");

            migrationBuilder.DropColumn(
                name: "ItemContaID",
                table: "SolicitacaoServico");

            migrationBuilder.DropColumn(
                name: "SubItemContaID",
                table: "SolicitacaoServico");

            migrationBuilder.DropColumn(
                name: "UnidadeMedida",
                table: "Produto");

            migrationBuilder.RenameColumn(
                name: "UnidadeMedida",
                table: "SolicitacaoServicoItem",
                newName: "Unidade");
        }
    }
}
