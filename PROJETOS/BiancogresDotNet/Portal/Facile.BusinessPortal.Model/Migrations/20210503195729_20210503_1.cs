using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20210503_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ResponsavelFornecedor",
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
                    UsuarioID = table.Column<long>(nullable: false),
                    FornecedorID = table.Column<long>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ResponsavelFornecedor", x => x.ID);
                    table.ForeignKey(
                        name: "FK_ResponsavelFornecedor_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ResponsavelFornecedor_Fornecedor_FornecedorID",
                        column: x => x.FornecedorID,
                        principalTable: "Fornecedor",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ResponsavelFornecedor_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ResponsavelFornecedor_Usuario_UsuarioID",
                        column: x => x.UsuarioID,
                        principalTable: "Usuario",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ResponsavelFornecedor_EmpresaID",
                table: "ResponsavelFornecedor",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_ResponsavelFornecedor_FornecedorID",
                table: "ResponsavelFornecedor",
                column: "FornecedorID");

            migrationBuilder.CreateIndex(
                name: "IX_ResponsavelFornecedor_UnidadeID",
                table: "ResponsavelFornecedor",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_ResponsavelFornecedor_UsuarioID",
                table: "ResponsavelFornecedor",
                column: "UsuarioID");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ResponsavelFornecedor");
        }
    }
}
