<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>

<c:set var="isEdit" value="${not empty sale}" />
<c:set var="title" value="${isEdit ? 'Edit Sale' : 'Record Sale'}" />

<ui:layout title="${title}" active="sales">
    <ui:header title="${title}" description="${isEdit ? 'Update sale record.' : 'Produce sale tied to an existing harvest record.'}">
        <a href="${pageContext.request.contextPath}/sales"
           class="inline-flex items-center text-sm font-medium text-zinc-600 hover:text-zinc-900 dark:text-zinc-300 dark:hover:text-white">
            ← Back
        </a>
    </ui:header>

    <div class="max-w-xl rounded-xl border border-zinc-200 bg-white p-6 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
        <form method="POST" action="${pageContext.request.contextPath}/sales${isEdit ? '/' += sale.id : ''}" class="space-y-6">
            <c:if test="${isEdit}">
                <input type="hidden" name="_method" value="PUT" />
            </c:if>

            <div>
                <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="harvest_id">
                    Harvest <span class="text-red-500">*</span>
                </label>
                <select id="harvest_id" name="harvest_id" required
                        class="w-full block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10">
                    <option value="">Select a harvest</option>
                    <c:forEach var="hItem" items="${harvests}">
                        <option value="${hItem.id}" ${(sale.harvest_id == hItem.id || selectedHarvestId == hItem.id) ? 'selected' : ''}>
                            ${h:date(hItem.harvested_on)} · ${h:e(hItem.tree_code)} (${h:e(hItem.type_name)}) — ${h:number(hItem.quantity)} ${hItem.unit}
                            <c:if test="${not empty hItem.remaining_qty}"> (Remaining: ${h:number(hItem.remaining_qty)})</c:if>
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="buyer_name">
                        Buyer Name <span class="text-red-500">*</span>
                    </label>
                    <input id="buyer_name" name="buyer_name" type="text" required value="${h:e(sale.buyer_name)}" placeholder="e.g. Fresh Market"
                           class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10" />
                </div>

                <div>
                    <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="sold_on">
                        Sold on <span class="text-red-500">*</span>
                    </label>
                    <input id="sold_on" name="sold_on" type="date" required value="${sale.sold_on}"
                           class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10" />
                </div>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="quantity">
                        Quantity <span class="text-red-500">*</span>
                    </label>
                    <input id="quantity" name="quantity" type="number" step="0.01" min="0.01" required value="${sale.quantity}"
                           oninput="updateTotal()"
                           class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10" />
                </div>

                <div>
                    <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="unit_price">
                        Unit Price (IDR) <span class="text-red-500">*</span>
                    </label>
                    <input id="unit_price" name="unit_price" type="number" step="0.01" min="0.01" required value="${sale.unit_price}"
                           oninput="updateTotal()"
                           class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10" />
                </div>
            </div>

            <div>
                <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2">Total Amount (Computed)</label>
                <div id="total_display" class="w-full h-10 px-3 flex items-center bg-zinc-50 dark:bg-zinc-800/50 rounded-lg text-sm font-semibold text-green-700 dark:text-green-400 border border-zinc-200 dark:border-zinc-700">
                    ${empty sale.total_amount ? 'IDR 0' : h:money(sale.total_amount)}
                </div>
            </div>

            <div>
                <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="notes">Notes</label>
                <textarea id="notes" name="notes" rows="3" placeholder="Payment terms, delivery receipt, etc."
                          class="w-full border block appearance-none text-sm rounded-lg py-2 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10">${h:e(sale.notes)}</textarea>
            </div>

            <div class="flex items-center justify-end gap-3 pt-4 border-t border-zinc-100 dark:border-zinc-800">
                <a href="${pageContext.request.contextPath}/sales"
                   class="px-4 py-2 text-sm font-medium text-zinc-700 dark:text-zinc-300 hover:text-zinc-900">Cancel</a>
                <button type="submit"
                        class="px-5 py-2.5 rounded-lg bg-[var(--color-accent)] text-white text-sm font-semibold hover:opacity-90 shadow-sm">
                    ${isEdit ? 'Save changes' : 'Record sale'}
                </button>
            </div>
        </form>
    </div>

    <script>
    function updateTotal() {
        var q = parseFloat(document.getElementById('quantity').value) || 0;
        var p = parseFloat(document.getElementById('unit_price').value) || 0;
        var t = q * p;
        document.getElementById('total_display').innerText = 'IDR ' + t.toLocaleString('en-US', {maximumFractionDigits: 2});
    }
    </script>
</ui:layout>
