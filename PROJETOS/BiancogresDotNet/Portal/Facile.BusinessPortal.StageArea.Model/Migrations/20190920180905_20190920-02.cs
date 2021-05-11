using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _2019092002 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ProcessoEmpresa",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    ChaveUnica = table.Column<string>(nullable: false),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: false),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    StatusIntegracao = table.Column<int>(nullable: false),
                    DataHoraIntegracao = table.Column<DateTime>(nullable: true),
                    MensagemRetorno = table.Column<string>(nullable: true),
                    ProcessoIntegracao = table.Column<int>(nullable: false),
                    EmpresaInterfaceID = table.Column<long>(nullable: false),
                    Habilitado = table.Column<bool>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ProcessoEmpresa", x => x.ID);
                    table.ForeignKey(
                        name: "FK_ProcessoEmpresa_EmpresaInterface_EmpresaInterfaceID",
                        column: x => x.EmpresaInterfaceID,
                        principalTable: "EmpresaInterface",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ProcessoEmpresa_EmpresaInterfaceID",
                table: "ProcessoEmpresa",
                column: "EmpresaInterfaceID");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ProcessoEmpresa");
        }
    }
}
