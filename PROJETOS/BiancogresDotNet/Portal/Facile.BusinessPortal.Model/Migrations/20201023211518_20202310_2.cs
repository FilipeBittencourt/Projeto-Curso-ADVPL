using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20202310_2 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "RPV",
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
                    NumeroContrato = table.Column<string>(nullable: true),
                    Item = table.Column<string>(nullable: true),
                    CodigoProduto = table.Column<string>(nullable: true),
                    NomeProduto = table.Column<string>(nullable: true),
                    QuantidadeProduto = table.Column<decimal>(nullable: false),
                    Contato = table.Column<string>(nullable: true),
                    Email = table.Column<string>(nullable: true),
                    Observacao = table.Column<string>(nullable: true),
                    DataLiberacao = table.Column<DateTime>(nullable: false),
                    NumeroControleParticipante = table.Column<string>(nullable: true),
                    Status = table.Column<bool>(nullable: false),
                    DataMedicao = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RPV", x => x.ID);
                    table.ForeignKey(
                        name: "FK_RPV_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_RPV_Fornecedor_FornecedorID",
                        column: x => x.FornecedorID,
                        principalTable: "Fornecedor",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_RPV_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_RPV_EmpresaID",
                table: "RPV",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_RPV_FornecedorID",
                table: "RPV",
                column: "FornecedorID");

            migrationBuilder.CreateIndex(
                name: "IX_RPV_UnidadeID",
                table: "RPV",
                column: "UnidadeID");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "RPV");
        }
    }
}
